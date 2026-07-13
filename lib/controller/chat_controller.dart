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

  RxList<MessageModel> pendingMessages = <MessageModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> sendTextMessage({
    required String receiverId,
    required String text,
  }) async {
    isLoading.value = true;

    try {
      final roomId = roomController.getRoomId(receiverId);

      await roomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: '',
      );

      final messageRef = db
          .collection("chats")
          .doc(roomId)
          .collection("messages")
          .doc();

      final message = MessageModel(
        id: messageRef.id,
        senderId: auth.currentUser!.uid,
        receiverId: receiverId,
        message: text,
        type: MessageType.text,
        mediaUrl: "",
        timeStamp: DateTime.now(),
        status: MessageStatus.sending,
        reactions: {},
        replyMessageId: "",
        isDeleted: false,
      );

      pendingMessages.add(message);

      await messageRef.set({
        ...message.toJson(),
        "timeStamp": FieldValue.serverTimestamp(),
      });

      // pendingMessages.removeWhere((m) => m.id == message.id);

      await messageRef.update({"status": MessageStatus.sent.name});

      roomController.updateRoom(targetUserId: receiverId, lastMessage: text);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<MessageModel>> getMessages(String roomId) {
    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy("timeStamp", descending: true)
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
