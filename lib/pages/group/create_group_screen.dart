import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'create_group_details_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final UserContactController contactController = Get.find();
  final ChatRoomController chatRoomController = Get.find();

  final List<UserModel> selectedUsers = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Group"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search connected contacts...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final currentUid = FirebaseAuth.instance.currentUser!.uid;
        
        // Get user IDs of people you have a 1v1 chat with
        final connectedUserIds = chatRoomController.chatRooms
            .where((room) => !room.isGroup)
            .expand((room) => room.participants)
            .where((uid) => uid != currentUid)
            .toSet();

        // Filter user list to only show connected users
        final connectedUsers = contactController.userList
            .where((user) => connectedUserIds.contains(user.uid))
            .toList();

        // Further filter by search query
        final filteredUsers = connectedUsers.where((user) {
          return user.name.toLowerCase().contains(searchQuery) ||
                 user.email.toLowerCase().contains(searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text("No connected contacts found"),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (_, index) {
            final user = filteredUsers[index];
            final selected = selectedUsers.any((u) => u.uid == user.uid);

            return CheckboxListTile(
              value: selected,
              secondary: CircleAvatar(
                backgroundImage: user.profilePic.isNotEmpty 
                    ? CachedNetworkImageProvider(user.profilePic)
                    : null,
                child: user.profilePic.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(user.name),
              subtitle: Text(user.about),
              onChanged: (_) {
                setState(() {
                  if (selected) {
                    selectedUsers.removeWhere((u) => u.uid == user.uid);
                  } else {
                    selectedUsers.add(user);
                  }
                });
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedUsers.isEmpty) {
            Get.snackbar("Error", "Select at least one member");
            return;
          }

          Get.to(() => CreateGroupDetailsScreen(members: selectedUsers));
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
