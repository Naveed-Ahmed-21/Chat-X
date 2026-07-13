import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/model/chat_room_model.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/chat_screen.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/chat_tile.dart';
import 'package:chatx_app/utils/date_time_formatter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatRoomList extends StatelessWidget {
  ChatRoomList({super.key});

  final ChatRoomController roomController = Get.find<ChatRoomController>();

  final UserContactController userController =
      Get.find<UserContactController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatRoomModel>>(
      stream: roomController.getChatRooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                      AppImages.appLogo,
                    scale: 2,
                  ),
                  SizedBox(height: 20,),

                  const Text("No conversations yet"),
                ],
              )
          );
        }

        final rooms = snapshot.data!;

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];

            final otherUserId = room.participants.firstWhere(
              (uid) => uid != FirebaseAuth.instance.currentUser!.uid,
            );

            return FutureBuilder<UserModel?>(
              future: userController.getUserById(otherUserId),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox();
                }

                final user = userSnapshot.data!;

                return InkWell(
                  onTap: () {
                    Get.to(() => ChatScreen(user: user));
                  },
                  child: ChatTile(
                    imageUrl: user.profilePic,
                    name: user.name,
                    lastMessage: room.lastMessage,
                    lastTime: DateTimeFormatter.formatLastMessageTime(
                      room.lastMessageTimestamp,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
