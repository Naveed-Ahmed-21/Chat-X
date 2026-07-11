import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../chatPage/chat_screen.dart';

class ChatLists extends StatelessWidget {
  ChatLists({super.key});

  final UserContactController userContactController = Get.find<UserContactController>();

  @override
  Widget build(BuildContext context) {
    return  Obx((){
      if (userContactController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      return ListView.builder(

        itemCount: userContactController.userList.length,

        itemBuilder: (context, index) {
          final user = userContactController.userList[index];

          return InkWell(
            onTap: () {
              Get.to(() => ChatScreen(user: user));
            },
            child: ChatTile(
              imageUrl: user.profilePic,
              name: user.name,
              lastMessage: "",
              lastTime: user.lastOnlineStatus,
            ),
          );
        },
      );
    });
  }
}
