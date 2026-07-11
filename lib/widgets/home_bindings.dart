import 'package:chatx_app/controller/auth_controller.dart';
import 'package:chatx_app/pages/screens/authentication/auth_screen.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/home_screen.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../controller/chat_controller.dart';
import '../controller/chat_room_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/user_contact_controller.dart';


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => UserContactController());
    Get.lazyPut(() => ChatRoomController());
    Get.lazyPut(() => ChatController());
  }
}