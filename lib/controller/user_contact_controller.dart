import 'package:chatx_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:async';

class UserContactController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _userSubscription;

  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUserLists();
  }


  Future<void> getUserLists() async {
    try {
      final currentUid = auth.currentUser!.uid;

      isLoading.value = true;

      userList.clear();

      await _userSubscription?.cancel();

      _userSubscription = db
          .collection("users")
          .snapshots()
          .listen((snapshot) {
        userList.assignAll(
          snapshot.docs
              .map((doc) => UserModel.fromJson(doc.data()))
              .where((user) => user.uid != currentUid)
              .toList(),
        );

        isLoading.value = false;
      });
    } catch (e) {
      isLoading.value = false;
      print(e);
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await db.collection("users").doc(uid).get();

      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

}
