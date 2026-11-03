import 'dart:io';
import 'package:chatx_app/model/chat_room_model.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/controller/group_chat_controller.dart';
import 'package:chatx_app/pages/group/add_members_screen.dart';
import 'package:chatx_app/services/upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/widgets/media/image_viewer_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:chatx_app/pages/screens/presentation/chatPage/shared_assets_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  const GroupInfoScreen({super.key, required this.chatRoom});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final UserContactController userController = Get.find<UserContactController>();
  final GroupController groupController = Get.find<GroupController>();
  final UploadService uploadService = UploadService();

  late TextEditingController nameController;
  late TextEditingController descController;

  bool isEditing = false;
  bool isLoading = false;
  XFile? newImage;

  // Using a Stream for real-time updates of group info
  late Stream<DocumentSnapshot<Map<String, dynamic>>> groupStream;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.chatRoom.groupName);
    descController = TextEditingController();
    groupStream = FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatRoom.id)
        .snapshots();
    _fetchDescription();
  }

  Future<void> _fetchDescription() async {
    final doc = await FirebaseFirestore.instance.collection("chats").doc(widget.chatRoom.id).get();
    if (doc.exists && mounted) {
      setState(() {
        descController.text = doc.data()?['groupDescription'] ?? "";
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        newImage = picked;
      });
    }
  }

  Future<void> _updateGroup() async {
    setState(() => isLoading = true);
    try {
      String imageUrl = widget.chatRoom.groupImage; // Default or fetched from stream in real app
      // We should really get the latest image from the stream before updating
      final doc = await FirebaseFirestore.instance.collection("chats").doc(widget.chatRoom.id).get();
      imageUrl = doc.data()?['groupImage'] ?? imageUrl;

      if (newImage != null) {
        imageUrl = await uploadService.uploadChatImage(newImage!.path);
      }

      await groupController.updateGroupInfo(
        roomId: widget.chatRoom.id,
        name: nameController.text.trim(),
        description: descController.text.trim(),
        image: imageUrl,
      );

      setState(() {
        isEditing = false;
        newImage = null;
      });
      Get.snackbar("Success", "Group updated successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _buildMediaTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildHeaderAction(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF131524), // Background of button matches main background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberOptions(UserModel user, bool isAdmin, bool isCurrentUserAdmin) {
    if (!isCurrentUserAdmin || user.uid == FirebaseAuth.instance.currentUser?.uid) return;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("View Profile"),
                onTap: () {
                  Get.back();
                  Get.toNamed('/userProfileScreen', arguments: user);
                },
              ),
              if (!isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings),
                  title: const Text("Make Group Admin"),
                  onTap: () async {
                    Get.back();
                    await groupController.makeAdmin(widget.chatRoom.id, user.uid, user.name);
                    Get.snackbar("Success", "${user.name} is now an admin");
                  },
                ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text("Dismiss as Admin"),
                  onTap: () async {
                    Get.back();
                    await groupController.dismissAdmin(widget.chatRoom.id, user.uid, user.name);
                    Get.snackbar("Success", "${user.name} is no longer an admin");
                  },
                ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
                title: const Text("Remove from Group", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Get.back();
                  await groupController.removeMember(widget.chatRoom.id, user.uid, user.name);
                  Get.snackbar("Removed", "${user.name} removed from group");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: groupStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Color(0xFF131524),
            body: Center(child: Text("Error loading data", style: TextStyle(color: Colors.white))),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF131524),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doc = snapshot.data;
        if (doc == null || !doc.exists) {
          return const Scaffold(
            backgroundColor: Color(0xFF131524),
            body: Center(child: Text("Group no longer exists", style: TextStyle(color: Colors.white))),
          );
        }

        final data = doc.data();
        if (data == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF131524),
            body: Center(child: Text("Error: No data available", style: TextStyle(color: Colors.white))),
          );
        }

        final chatRoom = ChatRoomModel.fromJson(data);
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final bool isCurrentUserAdmin = chatRoom.admins.contains(currentUid);
        // final Timestamp? createdAt = data['createdAt'] as Timestamp?;

        return Scaffold(
          backgroundColor: const Color(0xFF131524), // Dark background like the image
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Group Info"),
            actions: [
              if (isCurrentUserAdmin)
                IconButton(
                  onPressed: () {
                    if (isEditing) {
                      _updateGroup();
                    } else {
                      setState(() {
                        isEditing = true;
                        nameController.text = chatRoom.groupName;
                      });
                    }
                  },
                  icon: Icon(isEditing ? Icons.check : Icons.edit),
                ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Header Card Like Image
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF212338), // Lighter card background
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: isEditing
                                  ? _pickImage
                                  : () {
                                      if (chatRoom.groupImage.startsWith("http")) {
                                        Get.to(() => ImageViewerScreen(
                                          imageUrl: chatRoom.groupImage,
                                          heroTag: "group_profile_${chatRoom.id}",
                                        ));
                                      }
                                    },
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFFF9800), width: 3), // Orange/Gold border
                                    ),
                                    child: Hero(
                                      tag: "group_profile_${chatRoom.id}",
                                      child: CircleAvatar(
                                        radius: 65,
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        backgroundImage: newImage != null
                                            ? FileImage(File(newImage!.path))
                                            : (chatRoom.groupImage.isNotEmpty
                                                ? CachedNetworkImageProvider(chatRoom.groupImage)
                                                : null) as ImageProvider?,
                                        child: (newImage == null && chatRoom.groupImage.isEmpty)
                                            ? Image.asset(AppImages.appLogo, scale: 2)
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (isEditing)
                                    Positioned(
                                      bottom: 5,
                                      right: 5,
                                      child: CircleAvatar(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        radius: 18,
                                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isEditing)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: TextField(
                                  controller: nameController,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: "Group Name",
                                    hintStyle: TextStyle(color: Colors.white54),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              )
                            else
                              Text(
                                chatRoom.groupName,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            const SizedBox(height: 5),
                            if (!isEditing)
                              Text(
                                descController.text.isEmpty ? "No Description Available" : descController.text,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (isCurrentUserAdmin)
                                  _buildHeaderAction(context, Icons.person_add, "Add", Colors.white, () async {
                                    final result = await Get.to(() => AddGroupMembersScreen(
                                      roomId: chatRoom.id,
                                      currentMemberIds: chatRoom.participants,
                                    ));
                                    if (result == true) {}
                                  }),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (isEditing)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF212338),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Edit Description",
                                style: TextStyle(
                                  color: Color(0xFFFF9800),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: descController,
                                maxLines: null,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: "Add group description...",
                                  hintStyle: TextStyle(color: Colors.white38),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // Media Tiles Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212338),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildMediaTile(context, "Media", Icons.image, Colors.blue, () {
                              Get.to(() => SharedAssetsScreen(roomId: chatRoom.id, chatName: chatRoom.groupName));
                            }),
                            const Divider(height: 1, thickness: 0.5, color: Colors.white10, indent: 60),
                            _buildMediaTile(context, "Links", Icons.link, Colors.green, () {
                              Get.to(() => SharedAssetsScreen(roomId: chatRoom.id, chatName: chatRoom.groupName));
                            }),
                            const Divider(height: 1, thickness: 0.5, color: Colors.white10, indent: 60),
                            _buildMediaTile(context, "Docs", Icons.insert_drive_file, Colors.orange, () {
                              Get.to(() => SharedAssetsScreen(roomId: chatRoom.id, chatName: chatRoom.groupName));
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Members List Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Members",
                            style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Members List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: chatRoom.participants.length,
                        itemBuilder: (context, index) {
                          final userId = chatRoom.participants[index];
                          final bool isThisUserAdmin = chatRoom.admins.contains(userId);

                          return FutureBuilder<UserModel?>(
                            future: userController.getUserById(userId),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) return const SizedBox(height: 70);
                              final user = userSnapshot.data!;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF212338), // Member item background
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    onLongPress: () => _showMemberOptions(user, isThisUserAdmin, isCurrentUserAdmin),
                                    onTap: () => Get.toNamed('/userProfileScreen', arguments: user),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundImage: user.profilePic.isNotEmpty
                                          ? CachedNetworkImageProvider(user.profilePic)
                                          : null,
                                      child: user.profilePic.isEmpty ? const Icon(Icons.person) : null,
                                    ),
                                    title: Text(
                                      user.uid == currentUid ? "You" : user.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      user.email,
                                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                                    ),
                                    trailing: Text(
                                      isThisUserAdmin ? "Admin" : "User",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isThisUserAdmin ? const Color(0xFFFF9800) : Colors.white38,
                                        fontWeight: isThisUserAdmin ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Exit Group Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ListTile(
                          onTap: () async {
                            final confirm = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text("Exit Group?"),
                                content: const Text("Are you sure you want to leave this group?"),
                                actions: [
                                  TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text("Exit", style: TextStyle(color: Colors.red))
                                  ),
                                ],
                              )
                            );
                            if (confirm == true) {
                              await groupController.exitGroup(widget.chatRoom.id);
                              Get.offAllNamed("/homeScreen");
                            }
                          },
                          leading: const Icon(Icons.exit_to_app, color: Colors.red),
                          title: const Text("Exit Group", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                          ),
                        ),
                      ),

                      if (isCurrentUserAdmin) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: ListTile(
                            onTap: () async {
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text("Delete Group?"),
                                  content: const Text("This will permanently delete the group and all its messages for everyone."),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.red))
                                    ),
                                  ],
                                )
                              );
                              if (confirm == true) {
                                await groupController.deleteGroup(widget.chatRoom.id);
                                Get.offAllNamed("/homeScreen");
                              }
                            },
                            leading: const Icon(Icons.delete_forever, color: Colors.red),
                            title: const Text("Delete Group", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
