import 'dart:io';
import 'package:chatx_app/model/chat_room_model.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/controller/group_chat_controller.dart';
import 'package:chatx_app/pages/group/add_members_screen.dart';
import 'package:chatx_app/services/upload_service.dart';
import 'package:chatx_app/utils/date_time_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatx_app/config/imgepaths.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  void _showMemberOptions(UserModel user, bool isAdmin, bool isCurrentUserAdmin) {
    if (!isCurrentUserAdmin || user.uid == FirebaseAuth.instance.currentUser?.uid) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                  await groupController.makeAdmin(widget.chatRoom.id, user.uid);
                  Get.snackbar("Success", "${user.name} is now an admin");
                },
              ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
              title: const Text("Remove from Group", style: TextStyle(color: Colors.red)),
              onTap: () async {
                Get.back();
                await groupController.removeMember(widget.chatRoom.id, user.uid);
                Get.snackbar("Removed", "${user.name} removed from group");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: groupStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text("Error loading data")));
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        final data = snapshot.data!.data()!;
        final chatRoom = ChatRoomModel.fromJson(data);
        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final bool isCurrentUserAdmin = chatRoom.admins.contains(currentUid);
        final String createdByUid = data['createdBy'] ?? "";
        final Timestamp? createdAt = data['createdAt'] as Timestamp?;

        return Scaffold(
          appBar: AppBar(
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
                      const SizedBox(height: 20),
                      // Profile Picture
                      Center(
                        child: GestureDetector(
                          onTap: isEditing ? _pickImage : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
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
                              if (isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    radius: 20,
                                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Name and Status
                      if (isEditing)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: nameController,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: "Group Name",
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        )
                      else
                        Text(
                          chatRoom.groupName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        "Group · ${chatRoom.participants.length} members",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      
                      const SizedBox(height: 25),

                      // Description Section
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (isEditing)
                              TextField(
                                controller: descController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  hintText: "Add group description...",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              )
                            else
                              Text(
                                descController.text.isEmpty ? "No description provided" : descController.text,
                                style: const TextStyle(fontSize: 15),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Metadata Section
                      if (createdByUid.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          child: FutureBuilder<UserModel?>(
                            future: userController.getUserById(createdByUid),
                            builder: (context, userSnap) {
                              final creatorName = userSnap.data?.name ?? "someone";
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Created by $creatorName${createdAt != null ? ' on ${DateTimeFormatter.chatDate(createdAt.toDate())}' : ''}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              );
                            },
                          ),
                        ),

                      const Divider(height: 40),

                      // Members List Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${chatRoom.participants.length} Members",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if (isCurrentUserAdmin)
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await Get.to(() => AddGroupMembersScreen(
                                    roomId: chatRoom.id,
                                    currentMemberIds: chatRoom.participants,
                                  ));
                                  if (result == true) {
                                    // Refresh logic if needed, but stream handles it
                                  }
                                },
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text("Add"),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

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
                              
                              return ListTile(
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
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  user.about,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: isThisUserAdmin
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          "Admin",
                                          style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
