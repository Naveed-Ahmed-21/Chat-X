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

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  Future<void> getUserLists() async {
    try {
      final currentUid = auth.currentUser!.uid;

      isLoading.value = true;

      // Clear old data immediately
      userList.clear();

      // Cancel previous listener if any
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
}
