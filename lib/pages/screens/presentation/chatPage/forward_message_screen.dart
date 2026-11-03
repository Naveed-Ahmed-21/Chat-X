import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_controller.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForwardMessageScreen extends StatefulWidget {
  final MessageModel message;
  const ForwardMessageScreen({super.key, required this.message});

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final ChatRoomController roomController = Get.find();
  final ChatController chatController = Get.find();
  final UserContactController userController = Get.find();

  final List<String> selectedTargetIds = [];
  final Map<String, bool> isGroupMap = {};

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forward to..."),
      ),
      body: Obx(() {
        final rooms = roomController.chatRooms;
        final filteredRooms = rooms.where((r) {
           if (r.isGroup) {
             return r.groupName.toLowerCase().contains(searchQuery.toLowerCase());
           } else {
              final otherId = r.participants.firstWhere((uid) => uid != FirebaseAuth.instance.currentUser?.uid);
              final user = userController.userList.firstWhereOrNull((u) => u.uid == otherId);
              return user?.name.toLowerCase().contains(searchQuery.toLowerCase()) ?? false;
           }
        }).toList();

        return ListView.builder(
          itemCount: filteredRooms.length,
          itemBuilder: (context, index) {
            final room = filteredRooms[index];
            final targetId = room.isGroup ? room.id : room.participants.firstWhere((uid) => uid != FirebaseAuth.instance.currentUser?.uid);
            final isSelected = selectedTargetIds.contains(targetId);

            String name = "";
            String? imageUrl;

            if (room.isGroup) {
              name = room.groupName;
              imageUrl = room.groupImage;
            } else {
              final user = userController.userList.firstWhereOrNull((u) => u.uid == targetId);
              name = user?.name ?? "Unknown";
              imageUrl = user?.profilePic;
            }

            return ListTile(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTargetIds.remove(targetId);
                  } else {
                    selectedTargetIds.add(targetId);
                    isGroupMap[targetId] = room.isGroup;
                  }
                });
              },
              leading: CircleAvatar(
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith("http")
                    ? CachedNetworkImageProvider(imageUrl)
                    : null,
                child: imageUrl == null || imageUrl.isEmpty
                    ? (room.isGroup
                        ? ClipOval(child: Image.asset(AppImages.appLogo, width: 40, height: 40, fit: BoxFit.cover))
                        : Image.asset(AppImages.male, width: 40, height: 40, fit: BoxFit.cover))
                    : null,
              ),
              title: Text(name),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.circle_outlined),
            );
          },
        );
      }),
      floatingActionButton: selectedTargetIds.isEmpty ? null : FloatingActionButton(
        onPressed: () async {
          Get.back();
          await chatController.forwardMessage(
            targetIds: selectedTargetIds,
            message: widget.message,
            isGroupMap: isGroupMap,
          );
          Get.snackbar("Success", "Message forwarded");
        },
        child: const Icon(Icons.send),
      ),
    );
  }
}
