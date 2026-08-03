import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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
    final effectiveRoomId = roomId ?? roomController.getRoomId(receiverId);

    final doc = db.collection("chats").doc(effectiveRoomId).collection("messages").doc();

    Future roomFuture;
    if (isGroup) {
      roomFuture = roomController.updateLastMessage(
        roomId: effectiveRoomId,
        lastMessage: text,
      );
    } else {
      roomFuture = roomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: text,
      );
    }

    final reply = replyingMessage.value;
    final replyId = reply?.id ?? "";

    cancelReply();

    await doc.set({
      "id": doc.id,
      "senderId": auth.currentUser!.uid,
      "receiverId": receiverId,
      "message": text,
      "type": MessageType.text.name,
      "mediaUrl": "",

      "extension": "",
      "fileName": "",
      "duration": 0,
      "thumbnail": "",

      "timeStamp": Timestamp.now(),
      "status": MessageStatus.sent.name,
      "reactions": {},
      "replyMessageId": replyId,
      "isDeleted": false,
      "deletedFor": {},
      "isEdited": false,
    });

    await roomFuture;
  }

  Stream<List<MessageModel>> getMessages(String roomId) {
    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy("timeStamp", descending: false)
        .snapshots()
        .map((snapshot) {
          final uid = auth.currentUser!.uid;

          return snapshot.docs
              .map((e) => MessageModel.fromJson(e.data()))
              .where((m) => m.deletedFor[uid] != true)
              .toList();
        });
  }

  Future<void> markMessagesAsSeen(String roomId, String senderId) async {
    final currentUser = auth.currentUser!.uid;

    final snapshot = await db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .where("senderId", isEqualTo: senderId)
        .where("receiverId", isEqualTo: currentUser)
        .get();

    final batch = db.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {"status": MessageStatus.seen.name});
    }

    await batch.commit();
  }

  Future<void> markMessagesAsDelivered() async {
    try {
      final currentUser = auth.currentUser!.uid;

      final chatRooms = await db
          .collection("chats")
          .where("participants", arrayContains: currentUser)
          .get();

      final batch = db.batch();

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
        }
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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

    final doc = db.collection("chats").doc(effectiveRoomId).collection("messages").doc();

    Future roomFuture;
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

    await doc.set({
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
    });

    await roomFuture;
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

    final doc = db.collection("chats").doc(effectiveRoomId).collection("messages").doc();

    Future roomFuture;
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

    await doc.set({
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
    });

    await roomFuture;
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

    final doc = db.collection("chats").doc(effectiveRoomId).collection("messages").doc();

    Future roomFuture;
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

    await doc.set({
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
    });

    await roomFuture;
    return doc.id;
  }

  // Future<String> sendFileMessage({
  //   required String receiverId,
  //   required String fileUrl,
  //   required String fileName,
  //   String localPath = "",
  //   MessageStatus status = MessageStatus.sent,
  // }) async {
  //   final roomId = roomController.getRoomId(receiverId);
  //
  //   final doc = db.collection("chats").doc(roomId).collection("messages").doc();
  //
  //   final roomFuture = roomController.createOrUpdateRoom(
  //     receiverId: receiverId,
  //     lastMessage: "📄 $fileName",
  //   );
  //
  //   final reply = replyingMessage.value;
  //   final replyId = reply?.id ?? "";
  //
  //   cancelReply();
  //
  //   await doc.set({
  //     "id": doc.id,
  //     "senderId": auth.currentUser!.uid,
  //     "receiverId": receiverId,
  //     "message": "",
  //     "mediaUrl": fileUrl,
  //     "localPath": localPath,
  //     "type": MessageType.file.name,
  //     "fileName": fileName,
  //     "duration": 0,
  //     "thumbnail": "",
  //     "timeStamp": Timestamp.now(),
  //     "status": status.name,
  //     "replyMessageId": replyId,
  //     "reactions": {},
  //     "deletedFor": {},
  //     "isDeleted": false,
  //     "isEdited": false,
  //   });
  //
  //   await roomFuture;
  //   return doc.id;
  // }

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

    Future roomFuture;
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

    await doc.set({
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
    });

    await roomFuture;
    return doc.id;
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
