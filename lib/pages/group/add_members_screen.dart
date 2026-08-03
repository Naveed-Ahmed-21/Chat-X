import 'package:chatx_app/controller/group_chat_controller.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddGroupMembersScreen extends StatefulWidget {
  final String roomId;
  final List<String> currentMemberIds;
  const AddGroupMembersScreen({super.key, required this.roomId, required this.currentMemberIds});

  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  final UserContactController contactController = Get.find<UserContactController>();
  final GroupController groupController = Get.find<GroupController>();

  final List<UserModel> selectedUsers = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Members"),
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
                hintText: "Search contacts...",
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
        // Filter out users who are already members
        final availableUsers = contactController.userList
            .where((user) => !widget.currentMemberIds.contains(user.uid))
            .where((user) {
              return user.name.toLowerCase().contains(searchQuery) ||
                     user.email.toLowerCase().contains(searchQuery);
            }).toList();

        if (availableUsers.isEmpty) {
          return const Center(child: Text("No more contacts to add"));
        }

        return ListView.builder(
          itemCount: availableUsers.length,
          itemBuilder: (context, index) {
            final user = availableUsers[index];
            final isSelected = selectedUsers.any((u) => u.uid == user.uid);

            return ListTile(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedUsers.removeWhere((u) => u.uid == user.uid);
                  } else {
                    selectedUsers.add(user);
                  }
                });
              },
              leading: CircleAvatar(
                backgroundImage: user.profilePic.isNotEmpty 
                    ? CachedNetworkImageProvider(user.profilePic)
                    : null,
                child: user.profilePic.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: isSelected 
                  ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                  : const Icon(Icons.circle_outlined),
            );
          },
        );
      }),
      floatingActionButton: selectedUsers.isEmpty ? null : FloatingActionButton(
        onPressed: () async {
          final ids = selectedUsers.map((u) => u.uid).toList();
          await groupController.addMembers(widget.roomId, ids);
          Get.back(result: true);
          Get.snackbar("Success", "${selectedUsers.length} members added");
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
