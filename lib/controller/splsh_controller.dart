import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final auth = FirebaseAuth.instance;


  @override
  void onInit() {
    super.onInit();
    splashScreenHandler();
  }

  Future<void> splashScreenHandler() async {
    await Future.delayed(
      Duration(seconds: 3),
    );
    if (auth.currentUser != null) {
      await auth.currentUser!.reload();
      if (auth.currentUser?.emailVerified == true ||
          auth.currentUser?.providerData.any(
                (provider) => provider.providerId == 'google.com',
              ) ==
              true) {
        Get.offAllNamed('/homeScreen');
      } else {
        Get.offAllNamed('/verificationScreen');
      }
    } else {
      Get.offAllNamed('/authScreen');
    }
  }
}