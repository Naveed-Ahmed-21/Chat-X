import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final ChatRoomController roomController =
  Get.put(ChatRoomController());

  RxBool isLoading = false.obs;

  Future<void> sendMessage(
      String targetUserId,
      MessageModel messageModel,
      ) async {
    isLoading.value = true;

    try {
      final roomId = roomController.getRoomId(targetUserId);

      /// Create room if not exists
      await roomController.createRoom(targetUserId);

      /// Create Message Document
      final messageRef = db
          .collection("chats")
          .doc(roomId)
          .collection("messages")
          .doc();

      final message = messageModel.copyWith(
        id: messageRef.id,
      );

      /// Save Message
      await messageRef.set(message.toJson());

      /// Update Room
      await roomController.updateRoom(
        targetUserId: targetUserId,
        lastMessage: message.message,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<MessageModel>> getMessages(
      String roomId,
      ) {
    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy(
      "timeStamp",
      descending: false,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (e) => MessageModel.fromJson(e.data()),
      )
          .toList(),
    );
  }
}