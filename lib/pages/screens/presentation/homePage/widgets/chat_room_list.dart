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
  final String searchQuery;
  final bool onlyGroups;
  ChatRoomList({super.key, this.searchQuery = "", this.onlyGroups = false});

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
                  const SizedBox(height: 20,),

                  Text(onlyGroups ? "No groups yet" : "No conversations yet"),
                ],
              )
          );
        }

        var rooms = snapshot.data!;

        // Filter by group status
        rooms = rooms.where((room) => room.isGroup == onlyGroups).toList();

        // Simple filtering logic
        if (searchQuery.isNotEmpty) {
          rooms = rooms.where((room) {
            if (room.isGroup) {
              return room.groupName.toLowerCase().contains(searchQuery.toLowerCase());
            } else {
              // For 1v1, we need to check the other participant's name
              final otherUserId = room.participants.firstWhere(
                (uid) => uid != FirebaseAuth.instance.currentUser!.uid,
              );
              final otherUser = userController.userList.firstWhereOrNull((u) => u.uid == otherUserId);
              return otherUser?.name.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
            }
          }).toList();
        }

        if (rooms.isEmpty) {
          if (searchQuery.isNotEmpty) {
            return const Center(child: Text("No chats found matching your search"));
          } else {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                      AppImages.appLogo,
                    scale: 2,
                  ),
                  const SizedBox(height: 20,),

                  Text(onlyGroups ? "No groups yet" : "No conversations yet"),
                ],
              )
          );
          }
        }

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];

            if (room.isGroup) {
              return InkWell(
                onTap: () {
                  Get.to(
                    () => ChatScreen(
                      key: ValueKey(room.id),
                      chatRoom: room,
                    ),
                  );
                },
                child: ChatTile(
                  imageUrl: room.groupImage,
                  name: room.groupName,
                  lastMessage: room.lastMessage,
                  lastTime: DateTimeFormatter.formatLastMessageTime(
                    room.lastMessageTimestamp,
                  ),
                ),
              );
            }

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
                    Get.to(
                          () => ChatScreen(
                        key: ValueKey(user.uid),
                        user: user,
                      ),
                    );
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
