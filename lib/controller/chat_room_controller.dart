import 'package:chatx_app/model/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  RxList<ChatRoomModel> chatRooms = <ChatRoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    chatRooms.bindStream(getChatRooms());
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
    final roomId = getRoomId(receiverId);

    await db.collection("chats").doc(roomId).set({
      "id": roomId,

      "participants": [auth.currentUser!.uid, receiverId],

      "lastMessage": lastMessage,

      "lastMessageSenderId": auth.currentUser!.uid,

      "lastMessageTimestamp": FieldValue.serverTimestamp(),

      "createdAt": FieldValue.serverTimestamp(),

      "isGroup": false,

      "groupName": "",
    }, SetOptions(merge: true));
  }

  Future<void> updateRoom({
    required String targetUserId,
    required String lastMessage,
  }) async {
    final roomId = getRoomId(targetUserId);

    await db.collection("chats").doc(roomId).update({
      "lastMessage": lastMessage,
      "lastMessageSenderId": auth.currentUser!.uid,
      "lastMessageTimestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLastMessage({
    required String roomId,
    required String lastMessage,
  }) async {
    await db.collection("chats").doc(roomId).update({
      "lastMessage": lastMessage,
      "lastMessageSenderId": auth.currentUser!.uid,
      "lastMessageTimestamp": FieldValue.serverTimestamp(),
    });
  }

  /// Home Screen Stream
  Stream<List<ChatRoomModel>> getChatRooms() {
    return db
        .collection("chats")
        .where("participants", arrayContains: auth.currentUser!.uid)
        .orderBy("lastMessageTimestamp", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((e) => ChatRoomModel.fromJson(e.data()))
              .toList(),
        );
  }
}
