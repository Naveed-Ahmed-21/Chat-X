import 'package:chatx_app/model/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatRoomController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Generate Room ID
  String getRoomId(String targetUserId) {
    final currentUserId = auth.currentUser!.uid;

    final users = [currentUserId, targetUserId]..sort();

    return users.join("_");
  }

  /// Create Room if not exists
  Future<void> createRoom(String targetUserId) async {
    final roomId = getRoomId(targetUserId);

    final roomDoc = db.collection("chats").doc(roomId);

    final roomSnapshot = await roomDoc.get();

    if (roomSnapshot.exists) return;

    final room = ChatRoomModel(
      id: roomId,
      participants: [
        auth.currentUser!.uid,
        targetUserId,
      ],
      createdAt: DateTime.now(),
    );

    await roomDoc.set(room.toJson());
  }

  /// Update Room Metadata
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

  /// Home Screen Stream
  Stream<List<ChatRoomModel>> getChatRooms() {
    return db
        .collection("chats")
        .where(
      "participants",
      arrayContains: auth.currentUser!.uid,
    )
        .orderBy(
      "lastMessageTimestamp",
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (e) => ChatRoomModel.fromJson(e.data()),
      )
          .toList(),
    );
  }
}