import 'dart:async';
import 'dart:developer' as developer;

import 'package:chatx_app/controller/chat_controller.dart';
import 'package:chatx_app/model/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;
  StreamSubscription<List<ChatRoomModel>>? _roomsSubscription;

  @override
  void onInit() {
    super.onInit();
    refreshRooms();
  }

  void refreshRooms() {
    unawaited(_roomsSubscription?.cancel());
    _roomsSubscription = getChatRooms().listen(
      chatRooms.assignAll,
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'Could not load conversation rooms.',
          name: 'ChatRoomController',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  String getRoomId(String targetUserId) {
    final currentUserId = auth.currentUser!.uid;

    final users = [currentUserId, targetUserId]..sort();

    return users.join("_");
  }

  Future<void> createOrUpdateRoom({
    required String receiverId,
    required String lastMessage,
  }) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      final roomId = getRoomId(receiverId);

      await db.collection("chats").doc(roomId).set({
        "id": roomId,
        "participants": [currentUid, receiverId],
        "lastMessage": lastMessage,
        "lastMessageSenderId": currentUid,
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
        "createdAt": FieldValue.serverTimestamp(),
        "isGroup": false,
        "groupName": "",
        "deletedFor": {
          currentUid: false,
          receiverId: false,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Could not create or update a chat room.', name: 'ChatRoomController', error: e);
    }
  }

  Future<void> updateRoom({
    required String targetUserId,
    required String lastMessage,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) return;
      final roomId = getRoomId(targetUserId);

      await db.collection("chats").doc(roomId).set({
        "lastMessage": lastMessage,
        "lastMessageSenderId": currentUser.uid,
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
        "deletedFor": {
          currentUser.uid: false,
          targetUserId: false,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Could not update the chat room.', name: 'ChatRoomController', error: e);
    }
  }

  Future<void> updateLastMessage({
    required String roomId,
    required String lastMessage,
  }) async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) return;

      final doc = await db.collection("chats").doc(roomId).get();
      final participants = List<String>.from(doc.data()?['participants'] ?? [currentUser.uid]);
      final deletedForMap = <String, bool>{};
      for (var p in participants) {
        deletedForMap[p] = false;
      }

      await db.collection("chats").doc(roomId).set({
        "lastMessage": lastMessage,
        "lastMessageSenderId": currentUser.uid,
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
        "deletedFor": deletedForMap,
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Could not update the last message.', name: 'ChatRoomController', error: e);
    }
  }

  Future<void> deleteChatForMe(String roomId) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      await db.collection("chats").doc(roomId).set({
        "deletedFor": {
          currentUid: true,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Could not hide the chat for the current user.', name: 'ChatRoomController', error: e);
    }
  }

  Future<void> clearChatForUser(String roomId) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      await db.collection("chats").doc(roomId).set({
        "clearChatAt": {
          currentUid: FieldValue.serverTimestamp(),
        },
        "deletedFor": {
          currentUid: true,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Could not clear the chat for the current user.', name: 'ChatRoomController', error: e);
    }
  }

  Future<void> pinChat(String roomId, bool pin) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      if (pin) {
        await db.collection("chats").doc(roomId).set({
          "pinnedBy": FieldValue.arrayUnion([currentUid]),
        }, SetOptions(merge: true));
      } else {
        await db.collection("chats").doc(roomId).set({
          "pinnedBy": FieldValue.arrayRemove([currentUid]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      developer.log('Could not update the chat pin.', name: 'ChatRoomController', error: e);
    }
  }

  Future<void> setNickname(String roomId, String nickname) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      await db.collection("chats").doc(roomId).set({
        "nicknames": {
          currentUid: nickname,
        }
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Could not update the chat nickname.', name: 'ChatRoomController', error: e);
    }
  }

  /// Home Screen Stream
  Stream<List<ChatRoomModel>> getChatRooms() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return db
        .collection("chats")
        .where("participants", arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      final currentUid = uid;
      final rooms = snapshot.docs
          .map((e) {
            try {
              final data = e.data();
              // Older room documents may not contain the redundant `id` field.
              // The Firestore document ID is the source of truth in that case.
              final storedId = data['id'];
              final room = ChatRoomModel.fromJson({
                ...data,
                'id': storedId is String && storedId.trim().isNotEmpty
                    ? storedId
                    : e.id,
              });
              if (Get.isRegistered<ChatController>()) {
                Get.find<ChatController>().markMessagesAsDelivered(room.id);
              }
              return room;
            } catch (error, stackTrace) {
              developer.log(
                'Skipping invalid chat room ${e.id}.',
                name: 'ChatRoomController',
                error: error,
                stackTrace: stackTrace,
              );
              return null;
            }
          })
          .whereType<ChatRoomModel>()
          .where((room) => room.participants.contains(currentUid))
          .where((room) {
            final isDeleted = room.deletedFor[currentUid] == true;
            if (!isDeleted) return true;

            // If a new message arrived AFTER clearChatAt or deletedFor, show room
            final clearedAt = room.clearChatAt[currentUid];
            final lastMsgTime = room.lastMessageTimestamp;
            if (clearedAt != null && lastMsgTime != null && lastMsgTime.isAfter(clearedAt)) {
              return true;
            }
            return false;
          })
          .toList();

      // Sort by pinned first, then by last message timestamp
      rooms.sort((a, b) {
        final aPinned = a.pinnedBy.contains(currentUid);
        final bPinned = b.pinnedBy.contains(currentUid);

        if (aPinned && !bPinned) return -1;
        if (!aPinned && bPinned) return 1;

        // Use a very future date for null timestamps (pending sync)
        // to ensure they stay at the top.
        final aTime = a.lastMessageTimestamp ?? DateTime.now().add(const Duration(seconds: 1));
        final bTime = b.lastMessageTimestamp ?? DateTime.now().add(const Duration(seconds: 1));

        return bTime.compareTo(aTime);
      });

      return rooms;
    });
  }

  @override
  void onClose() {
    unawaited(_roomsSubscription?.cancel());
    super.onClose();
  }
}
