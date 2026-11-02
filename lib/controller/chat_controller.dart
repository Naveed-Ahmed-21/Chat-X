import 'dart:async';
import 'dart:developer' as developer;

import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/notification_service.dart';
import '../widgets/message_status.dart';
import '../widgets/message_type.dart';

class ChatController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ChatRoomController roomController = Get.find<ChatRoomController>();

  RxBool isLoading = false.obs;
  Rxn<MessageModel> replyingMessage = Rxn<MessageModel>();

  Future<void> sendTextMessage({
    required String receiverId,
    required String text,
    String? roomId,
    bool isGroup = false,
  }) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      final effectiveRoomId = roomId ?? roomController.getRoomId(receiverId);
      final doc = db
          .collection("chats")
          .doc(effectiveRoomId)
          .collection("messages")
          .doc();
      final reply = replyingMessage.value;
      final replyId = reply?.id ?? "";

      cancelReply();

      // Commit the room preview and message together. Firestore applies the
      // batch to its local cache immediately, so the bubble appears before
      // the server round trip and the room/message cannot get out of sync.
      final batch = db.batch();
      final now = Timestamp.now();
      final roomRef = db.collection("chats").doc(effectiveRoomId);
      final roomUpdate = <String, dynamic>{
        "lastMessage": text,
        "lastMessageSenderId": currentUid,
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
      };

      if (isGroup) {
        batch.set(roomRef, roomUpdate, SetOptions(merge: true));
      } else {
        if (receiverId.trim().isEmpty || receiverId == currentUid) {
          throw StateError(
            'Cannot send a message to an invalid chat participant.',
          );
        }
        batch.set(roomRef, {
          ...roomUpdate,
          "id": effectiveRoomId,
          "participants": [currentUid, receiverId],
          "createdAt": FieldValue.serverTimestamp(),
          "isGroup": false,
          "groupName": "",
          "deletedFor": {currentUid: false, receiverId: false},
        }, SetOptions(merge: true));
      }

      batch.set(doc, {
        "id": doc.id,
        "senderId": currentUid,
        "receiverId": receiverId,
        "message": text,
        "type": MessageType.text.name,
        "mediaUrl": "",
        "extension": "",
        "fileName": "",
        "duration": 0,
        "thumbnail": "",
        "timeStamp": now,
        "status": MessageStatus.sent.name,
        "reactions": {},
        "replyMessageId": replyId,
        "isDeleted": false,
        "deletedFor": {},
        "isEdited": false,
        "seenBy": [currentUid],
      });

      await batch.commit();
      _notifyRoom(effectiveRoomId, text);
    } catch (e) {
      developer.log(
        'Could not send a text message.',
        name: 'ChatController',
        error: e,
      );
      Get.snackbar(
        'Message not sent',
        'Check your connection and chat permissions, then try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _notifyRoom(String roomId, String preview) {
    if (!Get.isRegistered<NotificationService>()) return;
    unawaited(
      Get.find<NotificationService>().sendChatPushNotification(
        roomId: roomId,
        body: preview,
      ),
    );
  }

  void _queueMediaMessage({
    required DocumentReference<Map<String, dynamic>> messageRef,
    required Map<String, dynamic> data,
    required Future<void> roomWrite,
    required String roomId,
    required String notificationPreview,
  }) {
    // These writes are enqueued synchronously by Firestore and immediately
    // appear in its local cache. Do not make the upload wait for a server ACK.
    unawaited(roomWrite);
    unawaited(
      messageRef
          .set(data)
          .then<void>((_) => _notifyRoom(roomId, notificationPreview))
          .catchError((Object error, StackTrace stackTrace) {
            developer.log(
              'Could not save the outgoing media message.',
              name: 'ChatController',
              error: error,
              stackTrace: stackTrace,
            );
          }),
    );
  }

  Stream<List<MessageModel>> getMessages(String roomId) {
    return db
        .collection("chats")
        .doc(roomId)
        .snapshots()
        .asyncExpand((roomDoc) {
          final uid = auth.currentUser?.uid;
          if (uid == null) return Stream.value(<MessageModel>[]);

          final roomData = roomDoc.data();
          DateTime? clearChatAt;
          if (roomData != null && roomData['clearChatAt'] != null) {
            final clearMap = roomData['clearChatAt'] as Map<String, dynamic>?;
            final rawTime = clearMap?[uid];
            if (rawTime is Timestamp) {
              clearChatAt = rawTime.toDate();
            } else if (rawTime is String) {
              clearChatAt = DateTime.tryParse(rawTime);
            }
          }

          return db
              .collection("chats")
              .doc(roomId)
              .collection("messages")
              .snapshots(includeMetadataChanges: true)
              .map((snapshot) {
                final messages = snapshot.docs
                    .map((e) {
                      try {
                        final data = e.data();
                        // Show the small clock state while this device's
                        // optimistic Firestore write is still pending.
                        if (e.metadata.hasPendingWrites &&
                            data['senderId'] == uid) {
                          data['status'] = MessageStatus.sending.name;
                        }
                        return MessageModel.fromJson(data);
                      } catch (err) {
                        developer.log(
                          'Could not parse message ${e.id}.',
                          name: 'ChatController',
                          error: err,
                        );
                        return null;
                      }
                    })
                    .whereType<MessageModel>()
                    .where((m) {
                      if (m.deletedFor[uid] == true) return false;
                      if (clearChatAt != null && m.timeStamp != null) {
                        if (m.timeStamp!.isBefore(clearChatAt) ||
                            m.timeStamp!.isAtSameMomentAs(clearChatAt)) {
                          return false;
                        }
                      }
                      return true;
                    })
                    .toList();

                messages.sort((a, b) {
                  if (a.timeStamp == null && b.timeStamp == null) return 0;
                  if (a.timeStamp == null) return -1;
                  if (b.timeStamp == null) return 1;
                  return b.timeStamp!.compareTo(a.timeStamp!);
                });

                return messages;
              });
        })
        .handleError((error) {
          developer.log(
            'Message stream failed for chat $roomId.',
            name: 'ChatController',
            error: error,
          );
          return <MessageModel>[];
        });
  }

  Future<void> markMessagesAsSeen(
    String roomId,
    String targetId, {
    bool isGroup = false,
  }) async {
    try {
      final currentUser = auth.currentUser?.uid;
      if (currentUser == null) return;

      final query = db.collection("chats").doc(roomId).collection("messages");

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (isGroup) {
        snapshot = await query.get();
      } else {
        snapshot = await query
            .where("receiverId", isEqualTo: currentUser)
            .get();
      }

      if (snapshot.docs.isEmpty) return;

      final batch = db.batch();
      bool needsCommit = false;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (isGroup) {
          final seenBy = List<String>.from(data['seenBy'] ?? []);
          if (!seenBy.contains(currentUser)) {
            batch.update(doc.reference, {
              "seenBy": FieldValue.arrayUnion([currentUser]),
            });
            needsCommit = true;
          }
        } else {
          final currentStatus = data['status'] as String?;
          if (currentStatus != MessageStatus.seen.name) {
            batch.update(doc.reference, {
              "status": MessageStatus.seen.name,
              "seenBy": FieldValue.arrayUnion([currentUser]),
            });
            needsCommit = true;
          }
        }
      }

      if (needsCommit) {
        await batch.commit();
      }
    } catch (e) {
      developer.log(
        'Could not mark messages as seen.',
        name: 'ChatController',
        error: e,
      );
    }
  }

  Future<void> markMessagesAsDelivered([String? roomId]) async {
    try {
      final currentUser = auth.currentUser?.uid;
      if (currentUser == null) return;

      if (roomId != null && roomId.isNotEmpty) {
        final snapshot = await db
            .collection("chats")
            .doc(roomId)
            .collection("messages")
            .where("receiverId", isEqualTo: currentUser)
            .where("status", isEqualTo: MessageStatus.sent.name)
            .get();

        if (snapshot.docs.isEmpty) return;

        final batch = db.batch();
        for (final doc in snapshot.docs) {
          batch.update(doc.reference, {"status": MessageStatus.delivered.name});
        }
        await batch.commit();
      } else {
        final chatRooms = await db
            .collection("chats")
            .where("participants", arrayContains: currentUser)
            .get();

        final batch = db.batch();
        bool needsCommit = false;

        for (var room in chatRooms.docs) {
          final messages = await room.reference
              .collection("messages")
              .where("receiverId", isEqualTo: currentUser)
              .where("status", isEqualTo: MessageStatus.sent.name)
              .get();

          for (var message in messages.docs) {
            batch.update(message.reference, {
              "status": MessageStatus.delivered.name,
            });
            needsCommit = true;
          }
        }

        if (needsCommit) {
          await batch.commit();
        }
      }
    } catch (e) {
      developer.log(
        'Could not mark messages as delivered.',
        name: 'ChatController',
        error: e,
      );
    }
  }

  Future<void> setTypingStatus(String roomId, String status) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      await db.collection("chats").doc(roomId).set({
        "typingStatus": {currentUid: status},
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log(
        'Could not update typing status.',
        name: 'ChatController',
        error: e,
      );
    }
  }

  Future<void> clearTypingStatus(String roomId) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      await db.collection("chats").doc(roomId).set({
        "typingStatus": {currentUid: FieldValue.delete()},
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log(
        'Could not clear typing status.',
        name: 'ChatController',
        error: e,
      );
    }
  }

  Future<void> updateLastReadTimestamp(String roomId) async {
    try {
      final currentUid = auth.currentUser?.uid;
      if (currentUid == null) return;
      await db.collection("chats").doc(roomId).set({
        "lastReadTimestamp": {currentUid: FieldValue.serverTimestamp()},
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log(
        'Could not update the last-read timestamp.',
        name: 'ChatController',
        error: e,
      );
    }
  }

  void startReply(MessageModel message) {
    replyingMessage.value = message;
  }

  void cancelReply() {
    replyingMessage.value = null;
  }

  Future<void> deleteForEveryone({
    required String roomId,
    required String messageId,
  }) async {
    await db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({"message": "", "mediaUrl": "", "isDeleted": true});
  }

  Future<void> deleteForMe({
    required String roomId,
    required String messageId,
  }) async {
    final uid = auth.currentUser!.uid;

    await db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({"deletedFor.$uid": true});
  }

  Future<void> editMessage({
    required String roomId,
    required String messageId,
    required String newMessage,
  }) async {
    await db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .update({"message": newMessage, "isEdited": true});

    await db.collection("chats").doc(roomId).update({
      "lastMessage": newMessage,
    });
  }

  Future<void> reactToMessage({
    required String roomId,
    required String messageId,
    required String emoji,
    required Map<String, dynamic> reactions,
  }) async {
    final uid = auth.currentUser!.uid;

    final doc = db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .doc(messageId);

    if (reactions[uid] == emoji) {
      await doc.update({"reactions.$uid": FieldValue.delete()});
    } else {
      await doc.update({"reactions.$uid": emoji});
    }
  }

  Future<String> sendImageMessage({
    required String receiverId,
    required String imageUrl,
    String localPath = "",
    MessageStatus status = MessageStatus.sent,
    String caption = "",
    String? roomId,
    bool isGroup = false,
  }) async {
    final effectiveRoomId = roomId ?? roomController.getRoomId(receiverId);

    final doc = db
        .collection("chats")
        .doc(effectiveRoomId)
        .collection("messages")
        .doc();

    late final Future<void> roomFuture;
    if (isGroup) {
      roomFuture = roomController.updateLastMessage(
        roomId: effectiveRoomId,
        lastMessage: "📷 Photo",
      );
    } else {
      roomFuture = roomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: "📷 Photo",
      );
    }

    final reply = replyingMessage.value;

    final replyId = reply?.id ?? "";

    cancelReply();

    _queueMediaMessage(
      messageRef: doc,
      roomWrite: roomFuture,
      roomId: effectiveRoomId,
      notificationPreview: caption.isNotEmpty ? caption : 'Photo',
      data: {
        "id": doc.id,
        "senderId": auth.currentUser!.uid,
        "receiverId": receiverId,
        "message": caption,
        "mediaUrl": imageUrl,
        "localPath": localPath,
        "extension": "",
        "fileName": "",
        "duration": 0,
        "thumbnail": "",
        "type": MessageType.image.name,
        "timeStamp": Timestamp.now(),
        "status": status.name,
        "replyMessageId": replyId,
        "reactions": {},
        "deletedFor": {},
        "isDeleted": false,
        "isEdited": false,
        "seenBy": [auth.currentUser!.uid],
      },
    );
    return doc.id;
  }

  Future<String> sendVideoMessage({
    required String receiverId,
    required String videoUrl,
    required int duration,
    required String thumbnail,
    String localPath = "",
    MessageStatus status = MessageStatus.sent,
    String? roomId,
    bool isGroup = false,
  }) async {
    final effectiveRoomId = roomId ?? roomController.getRoomId(receiverId);

    final doc = db
        .collection("chats")
        .doc(effectiveRoomId)
        .collection("messages")
        .doc();

    late final Future<void> roomFuture;
    if (isGroup) {
      roomFuture = roomController.updateLastMessage(
        roomId: effectiveRoomId,
        lastMessage: "🎥 Video",
      );
    } else {
      roomFuture = roomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: "🎥 Video",
      );
    }

    final reply = replyingMessage.value;
    final replyId = reply?.id ?? "";

    cancelReply();

    _queueMediaMessage(
      messageRef: doc,
      roomWrite: roomFuture,
      roomId: effectiveRoomId,
      notificationPreview: 'Video',
      data: {
        "id": doc.id,
        "senderId": auth.currentUser!.uid,
        "receiverId": receiverId,
        "message": "",
        "mediaUrl": videoUrl,
        "localPath": localPath,
        "type": MessageType.video.name,
        "extension": "",
        "fileName": "",
        "duration": duration,
        "thumbnail": thumbnail,
        "timeStamp": Timestamp.now(),
        "status": status.name,
        "replyMessageId": replyId,
        "reactions": {},
        "deletedFor": {},
        "isDeleted": false,
        "isEdited": false,
        "seenBy": [auth.currentUser!.uid],
      },
    );
    return doc.id;
  }

  Future<String> sendAudioMessage({
    required String receiverId,
    required String audioUrl,
    required int duration,
    String localPath = "",
    MessageStatus status = MessageStatus.sent,
    String? roomId,
    bool isGroup = false,
  }) async {
    final effectiveRoomId = roomId ?? roomController.getRoomId(receiverId);

    final doc = db
        .collection("chats")
        .doc(effectiveRoomId)
        .collection("messages")
        .doc();

    late final Future<void> roomFuture;
    if (isGroup) {
      roomFuture = roomController.updateLastMessage(
        roomId: effectiveRoomId,
        lastMessage: "🎤 Voice message",
      );
    } else {
      roomFuture = roomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: "🎤 Voice message",
      );
    }

    final reply = replyingMessage.value;
    final replyId = reply?.id ?? "";

    cancelReply();

    _queueMediaMessage(
      messageRef: doc,
      roomWrite: roomFuture,
      roomId: effectiveRoomId,
      notificationPreview: 'Voice message',
      data: {
        "id": doc.id,
        "senderId": auth.currentUser!.uid,
        "receiverId": receiverId,
        "message": "",
        "mediaUrl": audioUrl,
        "localPath": localPath,
        "type": MessageType.audio.name,
        "extension": "",
        "fileName": "",
        "thumbnail": "",
        "duration": duration,
        "timeStamp": Timestamp.now(),
        "status": status.name,
        "replyMessageId": replyId,
        "reactions": {},
        "deletedFor": {},
        "isDeleted": false,
        "isEdited": false,
        "seenBy": [auth.currentUser!.uid],
      },
    );
    return doc.id;
  }

  Future<String> sendFileMessage({
    required String receiverId,
    required String fileUrl,
    required String fileName,
    required int fileSize,
    required String extension,
    String localPath = "",
    MessageStatus status = MessageStatus.sent,
    String? roomId,
    bool isGroup = false,
  }) async {
    final effectiveRoomId = roomId ?? roomController.getRoomId(receiverId);

    final doc = db
        .collection("chats")
        .doc(effectiveRoomId)
        .collection("messages")
        .doc();

    late final Future<void> roomFuture;
    if (isGroup) {
      roomFuture = roomController.updateLastMessage(
        roomId: effectiveRoomId,
        lastMessage: "📄 $fileName",
      );
    } else {
      roomFuture = roomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: "📄 $fileName",
      );
    }

    final reply = replyingMessage.value;
    final replyId = reply?.id ?? "";

    cancelReply();

    _queueMediaMessage(
      messageRef: doc,
      roomWrite: roomFuture,
      roomId: effectiveRoomId,
      notificationPreview: fileName.isNotEmpty ? fileName : 'File',
      data: {
        "id": doc.id,
        "senderId": auth.currentUser!.uid,
        "receiverId": receiverId,

        "message": "",
        "mediaUrl": fileUrl,
        "localPath": localPath,

        "type": MessageType.file.name,

        "fileName": fileName,
        "fileSize": fileSize,
        "extension": extension,

        "thumbnail": "",
        "duration": 0,

        "timeStamp": Timestamp.now(),
        "status": status.name,

        "replyMessageId": replyId,
        "reactions": {},
        "deletedFor": {},
        "isDeleted": false,
        "isEdited": false,
        "seenBy": [auth.currentUser!.uid],
      },
    );
    return doc.id;
  }

  Future<void> forwardMessage({
    required List<String> targetIds, // List of receiverIds or roomIds
    required MessageModel message,
    required Map<String, bool> isGroupMap, // targetId -> isGroup
  }) async {
    for (final targetId in targetIds) {
      final isGroup = isGroupMap[targetId] ?? false;
      final effectiveRoomId = isGroup
          ? targetId
          : roomController.getRoomId(targetId);

      if (message.type == MessageType.text) {
        await sendTextMessage(
          receiverId: targetId,
          text: message.message,
          roomId: effectiveRoomId,
          isGroup: isGroup,
        );
      } else if (message.type == MessageType.image) {
        await sendImageMessage(
          receiverId: targetId,
          imageUrl: message.mediaUrl,
          caption: message.message,
          roomId: effectiveRoomId,
          isGroup: isGroup,
        );
      }
      // Add other types as needed
    }
  }

  Future<void> updateMessage(
    String targetId, // Can be receiverId or roomId
    String messageId,
    Map<String, dynamic> data, {
    String? roomId,
  }) async {
    final effectiveRoomId = roomId ?? targetId;
    await db
        .collection("chats")
        .doc(effectiveRoomId)
        .collection("messages")
        .doc(messageId)
        .update(data);
  }
}
