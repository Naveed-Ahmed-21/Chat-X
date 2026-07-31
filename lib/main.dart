import 'package:chatx_app/config/pagepaths.dart';
import 'package:chatx_app/config/themes.dart';
import 'package:chatx_app/controller/chat_controller.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/services/upload_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'controller/auth_controller.dart';
import 'controller/profile_controller.dart';
import 'controller/user_contact_controller.dart';
import 'services/download_service.dart';
import 'widgets/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      initialRoute: "/splashScreen",
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(UploadService(), permanent: true);
    Get.put(DownloadService(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatRoomController(), fenix: true);
    Get.lazyPut(() => ChatController(), fenix: true);
    Get.lazyPut(() => UserContactController(), fenix: true);
  }
}
