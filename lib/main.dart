import 'package:chatx_app/config/pagepaths.dart';
import 'package:chatx_app/config/themes.dart';
import 'package:chatx_app/controller/chat_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/splashScreen/splash_screen.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'controller/auth_controller.dart';
import 'controller/profile_controller.dart';
import 'controller/user_contact_controller.dart';
import 'firebase_options.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: InitialBinding(),
      title: "Chat X",
      debugShowCheckedModeBanner: false,
      getPages: pagePath,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: SplashScreen(),
    );
  }
}


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserContactController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
    Get.put(ChatController(), permanent: true);
  }
}
