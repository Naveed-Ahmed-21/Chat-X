import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../model/message_model.dart';

class ChatController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  String getRoomId(String targetUserId) {
    final currentUserId = auth.currentUser!.uid;

    final users = [currentUserId, targetUserId]..sort();

    return users.join("_");
  }

  Future<void> sendMessage(
    String targetUserId,
    MessageModel messageModel,
  ) async {
    isLoading.value = true;
    String roomId = getRoomId(targetUserId);

    try {
      // Create a new document reference
      DocumentReference messageRef = db
          .collection("chats")
          .doc(roomId)
          .collection("messages")
          .doc();

      // Update the model with the generated message ID
      MessageModel message = messageModel.copyWith(id: messageRef.id);

      // Create/update the chat room document
      await db.collection("chats").doc(roomId).set({
        "participants": [auth.currentUser!.uid, targetUserId],
        "lastMessage": message.message,
        "lastMessageTime": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save the message
      await messageRef.set(message.toJson());
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      Center(child: Text("Something went wrong"));
    } finally {
      isLoading.value = false;
    }
  }

  Stream<List<MessageModel>> getMessages(String roomId) {

    return db
        .collection("chats")
        .doc(roomId)
        .collection("messages")
        .orderBy("timeStamp" , descending:  false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => MessageModel.fromJson(e.data()))
              .toList(),
        );
  }
}
