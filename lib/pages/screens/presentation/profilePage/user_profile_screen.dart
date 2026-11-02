import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/chat_screen.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/shared_assets_screen.dart';
import 'package:chatx_app/widgets/media/image_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../model/user_model.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});

  final UserModel user = Get.arguments as UserModel;
  final ChatRoomController chatRoomController = Get.find();

  @override
  Widget build(BuildContext context) {
    final String roomId = chatRoomController.getRoomId(user.uid);

    return Scaffold(
      backgroundColor: const Color(0xFF131524),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF212338),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (user.profilePic.startsWith("http")) {
                        Get.to(
                          () => ImageViewerScreen(
                            imageUrl: user.profilePic,
                            heroTag: "user_profile_${user.uid}",
                          ),
                        );
                      }
                    },
                    child: Hero(
                      tag: "user_profile_${user.uid}",
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        backgroundImage: user.profilePic.isNotEmpty
                            ? CachedNetworkImageProvider(user.profilePic)
                            : null,
                        child: user.profilePic.isEmpty
                            ? Image.asset(AppImages.male, scale: 2)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.about,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHeaderAction(
                        context,
                        Icons.wechat_outlined,
                        "Chat",
                        Colors.blue,
                        () {
                          Get.to(
                            () =>
                                ChatScreen(user: user, key: ValueKey(user.uid)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User Info Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF212338),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow("Email", user.email),
                  const Divider(color: Colors.white10, height: 20),
                  _buildInfoRow(
                    "Phone",
                    user.phoneNumber.isEmpty
                        ? "Not available"
                        : user.phoneNumber,
                  ),
                  const Divider(color: Colors.white10, height: 20),
                  _buildInfoRow(
                    "Created At",
                    user.createdAt.isEmpty ? "Not preferred" : user.createdAt,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Media Tiles Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Material(
                color: const Color(0xFF212338),
                borderRadius: BorderRadius.circular(15),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                  _buildMediaTile(
                    context,
                    "Media",
                    Icons.image,
                    Colors.blue,
                    () {
                      Get.to(
                        () => SharedAssetsScreen(
                          roomId: roomId,
                          chatName: user.name,
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white10,
                    indent: 60,
                  ),
                  _buildMediaTile(
                    context,
                    "Links",
                    Icons.link,
                    Colors.green,
                    () {
                      Get.to(
                        () => SharedAssetsScreen(
                          roomId: roomId,
                          chatName: user.name,
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white10,
                    indent: 60,
                  ),
                  _buildMediaTile(
                    context,
                    "Docs",
                    Icons.insert_drive_file,
                    Colors.orange,
                    () {
                      Get.to(
                        () => SharedAssetsScreen(
                          roomId: roomId,
                          chatName: user.name,
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white10,
                    indent: 60,
                  ),
                  _buildMediaTile(
                    context,
                    "Clear Chat",
                    Icons.cleaning_services_rounded,
                    Colors.redAccent,
                    () {
                      _showClearChatDialog(context, roomId);
                    },
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context, String roomId) {
    final chatRoomController = Get.find<ChatRoomController>();
    Get.defaultDialog(
      backgroundColor: const Color(0xFF212338),
      title: "Clear this chat?",
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      middleText:
          "Messages will be cleared from your chat history. The other person will still have them.",
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "Clear Chat",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      textCancel: "Cancel",
      cancelTextColor: Colors.white70,
      onConfirm: () async {
        await chatRoomController.clearChatForUser(roomId);
        Get.back();
        Get.snackbar("Chat Cleared", "Messages cleared from your history");
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.white38,
      ),
    );
  }

  Widget _buildHeaderAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF131524),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
