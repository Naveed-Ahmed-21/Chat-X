import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../widgets/message_status.dart';
import '../widgets/message_type.dart';

class ChatController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ChatRoomController roomController = Get.find<ChatRoomController>();

  RxBool isLoading = false.obs;

  Future<void> sendTextMessage({
    required String receiverId,
    required String text,
  }) async {
    final roomId = roomController.getRoomId(receiverId);

    final doc = db.collection("chats").doc(roomId).collection("messages").doc();

    final roomFuture = roomController.createOrUpdateRoom(
      receiverId: receiverId,
      lastMessage: text,
    );
    // await roomController.createOrUpdateRoom(
    //   receiverId: receiverId,
    //   lastMessage: text,
    // );

    await doc.set({
      "id": doc.id,
      "senderId": auth.currentUser!.uid,
      "receiverId": receiverId,
      "message": text,
      "type": MessageType.text.name,
      "mediaUrl": "",
      "timeStamp": Timestamp.now(),
      "status": MessageStatus.sent.name,
      "reactions": {},
      "replyMessageId": "",
      "isDeleted": false,
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
        .map(
          (snapshot) => snapshot.docs
              .map((e) => MessageModel.fromJson(e.data()))
              .toList(),
        );
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
      print(e);
    }
  }
}
