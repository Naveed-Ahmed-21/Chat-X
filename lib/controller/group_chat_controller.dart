import 'package:chatx_app/widgets/message_type.dart';
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

    await sendGroupNotification(doc.id, "You created group \"$name\"");
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

  Future<void> sendGroupNotification(String roomId, String text) async {
    final doc = db.collection("chats").doc(roomId).collection("messages").doc();
    final currentUid = auth.currentUser!.uid;

    await doc.set({
      "id": doc.id,
      "senderId": currentUid,
      "receiverId": roomId,
      "message": text,
      "type": MessageType.notification.name,
      "mediaUrl": "",
      "timeStamp": FieldValue.serverTimestamp(),
      "status": "sent",
      "reactions": {},
      "replyMessageId": "",
      "isDeleted": false,
      "deletedFor": {},
      "isEdited": false,
      "seenBy": [currentUid],
      "fileName": "",
      "fileSize": 0,
      "duration": 0,
      "thumbnail": "",
      "extension": "",
    });

    await db.collection("chats").doc(roomId).update({
      "lastMessage": text,
      "lastMessageSenderId": currentUid,
      "lastMessageTimestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> addMembers(String roomId, List<String> newMemberIds, List<String> memberNames) async {
    await db.collection("chats").doc(roomId).update({
      "participants": FieldValue.arrayUnion(newMemberIds),
    });

    final currentUserName = await _getCurrentUserName();
    final addedNames = memberNames.join(", ");
    await sendGroupNotification(roomId, "$currentUserName added $addedNames");
  }

  Future<void> makeAdmin(String roomId, String userId, String userName) async {
    await db.collection("chats").doc(roomId).update({
      "admins": FieldValue.arrayUnion([userId]),
    });
    final currentUserName = await _getCurrentUserName();
    await sendGroupNotification(roomId, "$currentUserName made $userName an admin");
  }

  Future<void> dismissAdmin(String roomId, String userId, String userName) async {
    await db.collection("chats").doc(roomId).update({
      "admins": FieldValue.arrayRemove([userId]),
    });
    final currentUserName = await _getCurrentUserName();
    await sendGroupNotification(roomId, "$currentUserName dismissed $userName as admin");
  }

  Future<void> removeMember(String roomId, String userId, String userName) async {
    await db.collection("chats").doc(roomId).update({
      "participants": FieldValue.arrayRemove([userId]),
      "admins": FieldValue.arrayRemove([userId]),
    });
    final currentUserName = await _getCurrentUserName();
    await sendGroupNotification(roomId, "$currentUserName removed $userName");
  }

  Future<void> exitGroup(String roomId) async {
    final currentUid = auth.currentUser!.uid;
    final currentUserName = await _getCurrentUserName();

    final docRef = db.collection("chats").doc(roomId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    List<String> participants = List<String>.from(data['participants'] ?? []);
    List<String> admins = List<String>.from(data['admins'] ?? []);

    participants.remove(currentUid);
    bool wasAdmin = admins.remove(currentUid);

    // If no admins left but there are participants, promote the first one
    if (wasAdmin && admins.isEmpty && participants.isNotEmpty) {
      String newAdminId = participants.first;
      admins.add(newAdminId);
      final newAdminDoc = await db.collection("users").doc(newAdminId).get();
      String newAdminName = newAdminDoc.data()?['name'] ?? "Someone";
      await sendGroupNotification(roomId, "$newAdminName is now an admin");
    }

    await docRef.update({
      "participants": participants,
      "admins": admins,
    });

    await sendGroupNotification(roomId, "$currentUserName left");
  }

  Future<void> deleteGroup(String roomId) async {
    // Delete all messages first (optional but good practice)
    final messages = await db.collection("chats").doc(roomId).collection("messages").get();
    final batch = db.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(db.collection("chats").doc(roomId));
    await batch.commit();
  }

  Future<String> _getCurrentUserName() async {
    final uid = auth.currentUser!.uid;
    final doc = await db.collection("users").doc(uid).get();
    return doc.data()?['name'] ?? "Someone";
  }
}
