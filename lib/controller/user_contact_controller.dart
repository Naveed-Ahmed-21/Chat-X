import 'dart:async';
import 'dart:developer' as developer;

import 'package:chatx_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserContactController extends GetxController {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  RxBool isLoading = false.obs;
  RxList<UserModel> userList = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = auth.authStateChanges().listen((user) {
      if (user != null) {
        getUserLists();
      } else {
        _userSubscription?.cancel();
        userList.clear();
        isLoading.value = false;
      }
    });
  }

  Future<void> getUserLists() async {
    try {
      final currentUid = auth.currentUser?.uid;

      if (currentUid == null) {
        await _userSubscription?.cancel();
        userList.clear();
        isLoading.value = false;
        return;
      }

      isLoading.value = true;

      await _userSubscription?.cancel();

      _userSubscription = db
          .collection("users")
          .snapshots()
          .listen(
            (snapshot) {
              final List<UserModel> loaded = [];
              for (var doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  final user = UserModel.fromJson(data);
                  if (user.uid.isNotEmpty && user.uid != currentUid) {
                    loaded.add(user);
                  }
                } catch (e) {
                  developer.log(
                    'Could not parse user profile ${doc.id}.',
                    name: 'UserContactController',
                    error: e,
                  );
                }
              }
              userList.assignAll(loaded);
              isLoading.value = false;
            },
            onError: (error) {
              developer.log(
                'User profile stream failed.',
                name: 'UserContactController',
                error: error,
              );
              isLoading.value = false;
            },
          );
    } catch (e) {
      isLoading.value = false;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    // 1. Check if user is already in the stream-fed list
    final cachedUser = userList.firstWhereOrNull((u) => u.uid == uid);
    if (cachedUser != null) return cachedUser;

    try {
      final doc = await db.collection("users").doc(uid).get();

      if (!doc.exists) return null;

      final user = UserModel.fromJson(doc.data()!);
      // Optionally add to list if needed, but the stream should pick it up eventually
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final snapshot = await db
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return UserModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.onClose();
  }
}
