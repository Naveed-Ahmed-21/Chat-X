import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GroupController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> createGroup({
    required String name,
    required String image,
    required List<String> members,
    String description = "",
  }) async {
    final doc = db.collection("chats").doc();

    final currentUid = auth.currentUser!.uid;

    final allMembers = {currentUid, ...members}.toList();

    await doc.set({
      "id": doc.id,
      "participants": allMembers,
      "lastMessage": "Group created",
      "lastMessageSenderId": currentUid,
      "lastMessageTimestamp": FieldValue.serverTimestamp(),
      "createdAt": FieldValue.serverTimestamp(),
      "isGroup": true,
      "groupName": name,
      "groupImage": image,
      "groupDescription": description,
      "createdBy": currentUid,
      "admins": [currentUid],
    });
  }

  Future<void> updateGroupInfo({
    required String roomId,
    required String name,
    required String description,
    required String image,
  }) async {
    await db.collection("chats").doc(roomId).update({
      "groupName": name,
      "groupDescription": description,
      "groupImage": image,
    });
  }

  Future<void> addMembers(String roomId, List<String> newMemberIds) async {
    await db.collection("chats").doc(roomId).update({
      "participants": FieldValue.arrayUnion(newMemberIds),
    });
  }

  Future<void> makeAdmin(String roomId, String userId) async {
    await db.collection("chats").doc(roomId).update({
      "admins": FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMember(String roomId, String userId) async {
    await db.collection("chats").doc(roomId).update({
      "participants": FieldValue.arrayRemove([userId]),
      "admins": FieldValue.arrayRemove([userId]),
    });
  }
}
