import 'dart:developer' as developer;

import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatx_app/services/notification_service.dart';

import 'chat_controller.dart';
import 'chat_room_controller.dart';

class AuthController extends GetxController {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  Future<void>? _googleSignInInitialization;

  Future<void> _initializeGoogleSignIn() {
    return _googleSignInInitialization ??= GoogleSignIn.instance.initialize();
  }

  Future<void> _sendVerificationEmail(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.reload();
      final user = auth.currentUser;
      if (user == null) return;
      if (!user.emailVerified) {
        await _sendVerificationEmail(user);
        Get.offAllNamed('/verificationScreen');
        return;
      }
      Get.offAllNamed("/homeScreen");
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
          await _sendVerificationEmail(user);
          Get.offAllNamed('/verificationScreen');
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

  Future<void> resendVerificationEmail() async {
    final user = auth.currentUser;
    if (user == null) return;
    try {
      await user.sendEmailVerification();
      Get.snackbar(
        'Verification email sent',
        'Check your inbox and spam folder.',
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Could not send email',
        e.message ?? 'Please try again later.',
      );
    }
  }

  Future<void> refreshVerificationStatus() async {
    final user = auth.currentUser;
    if (user == null) return;
    await user.reload();
    if (auth.currentUser?.emailVerified == true) {
      Get.offAllNamed('/homeScreen');
    } else {
      Get.snackbar(
        'Not verified yet',
        'Open the link sent to your email first.',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await auth.sendPasswordResetEmail(email: email.trim());
      Get.snackbar(
        'Reset email sent',
        'Check your inbox for the password reset link.',
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Reset failed', e.message ?? 'Please try again later.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final googleSignIn = GoogleSignIn.instance;
      await _initializeGoogleSignIn();
      final account = await googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google did not return an ID token. Check the Android OAuth client, '
          'package name, and signing certificate fingerprints in Firebase.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) return;
      await initUser(
        user.uid,
        user.displayName ?? 'Chat X user',
        user.phoneNumber ?? '',
        user.photoURL ?? '',
        user.email ?? '',
      );
      Get.offAllNamed('/homeScreen');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Google sign-in failed', e.message ?? 'Please try again.');
    } on GoogleSignInException catch (e) {
      developer.log(
        'Google account authentication failed (${e.code.name}).',
        name: 'AuthController',
        error: e,
      );
      Get.snackbar('Google sign-in failed', e.description ?? e.code.name);
    } on FirebaseException catch (e, stackTrace) {
      developer.log(
        'Could not save or load the signed-in user profile.',
        name: 'AuthController',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Google sign-in failed',
        e.code == 'permission-denied'
            ? 'Google authenticated you, but Firestore denied access to your profile. Check the Firestore rules.'
            : e.message ?? 'Could not finish setting up your profile.',
      );
    } on StateError catch (e) {
      developer.log(
        'Google sign-in configuration is incomplete.',
        name: 'AuthController',
        error: e,
      );
      Get.snackbar('Google sign-in setup issue', e.message.toString());
    } catch (e, stackTrace) {
      developer.log(
        'Google sign-in could not be completed.',
        name: 'AuthController',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Google sign-in failed',
        'Please check your connection and Google sign-in setup, then try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logoutUser() async {
    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().prepareForSignOut();
    }
    await auth.signOut();

    Get.delete<UserContactController>(force: true);
    Get.delete<ChatController>(force: true);
    Get.delete<ChatRoomController>(force: true);

    Get.offAllNamed("/authScreen");
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
    } catch (err, stackTrace) {
      developer.log(
        'Could not save the user profile.',
        name: 'AuthController',
        error: err,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
