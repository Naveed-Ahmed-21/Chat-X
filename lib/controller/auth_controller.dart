import 'package:chatx_app/controller/profile_controller.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';

class AuthController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;


  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      Get.put(ProfileController());
      Get.put(UserContactController());
      Get.put(ChatController());

      Get.offAllNamed('/homeScreen');

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(
    String name,
    String email,
    String password, {
    String phoneNumber = "",
  }) async {
    try {
      isLoading.value = true;
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        try {
          await initUser(user.uid, name, phoneNumber, "", email);
          Get.offAllNamed('/authScreen');
        } catch (e) {
          Get.snackbar("Error", "Couldn't save user profile");
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Registration Failed", e.message ?? "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    await auth.signOut();

    Get.deleteAll(force: true);

    Get.offAllNamed('/authScreen');
  }

  Future<void> initUser(
    String uid,
    String name,
    String phoneNumber,
    String profilePic,
    String email,
  ) async {
    var newUser = UserModel(
      uid: uid,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profilePic: profilePic,
      about: '',
      createdAt: '',
      lastOnlineStatus: '',
      status: '',
    );
    try {
      await db.collection("users").doc(uid).set(newUser.toJson());
    } catch (err) {
      print(err);
    }
  }
}
