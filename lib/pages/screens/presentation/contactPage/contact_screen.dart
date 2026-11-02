import 'package:chatx_app/controller/chat_controller.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/chat_screen.dart';
import 'package:chatx_app/pages/screens/presentation/contactPage/widgets/new_contact_tile.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../config/imgepaths.dart';
import '../../../../controller/user_contact_controller.dart';

class ContactController extends GetxController {
  RxBool isSearch = false.obs;
  RxString searchQuery = "".obs;

  void toggleSearch() {
    isSearch.toggle();
    if (!isSearch.value) {
      searchQuery.value = "";
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
}

class ContactScreen extends StatelessWidget {
  ContactScreen({super.key});

  final ContactController controller = Get.put(ContactController()); // For search
  final UserContactController userContactController =
      Get.find<UserContactController>();
  final ChatController chatController = Get.find<ChatController>();
  final ChatRoomController chatRoomController = Get.find<ChatRoomController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Obx(() {
          if (controller.isSearch.value) {
            return TextField(
              autofocus: true,
              onChanged: controller.updateSearchQuery,
              decoration: const InputDecoration(
                hintText: "Search contacts...",
                border: InputBorder.none,
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select Contact", style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 3),
              Obx(() => Text(
                    "${userContactController.userList.length} contacts",
                    style: Theme.of(context).textTheme.labelMedium,
                  )),
            ],
          );
        }),
        actions: [
          Obx(() {
            return IconButton(
              onPressed: controller.toggleSearch,
              icon: Icon(
                controller.isSearch.value ? Icons.close : Icons.search,
                size: 30,
              ),
            );
          }),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            NewContactTile(
              btnName: 'New Contact',
              icon: Icons.person_add_alt_rounded,
              ontap: () => _showNewContactDialog(context),
            ),
            const SizedBox(height: 10),
            NewContactTile(
              btnName: 'New Group',
              icon: Icons.group_add,
              ontap: () {
                Get.toNamed("/createGroupScreen");
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset(AppImages.appLogo, scale: 11),
                const SizedBox(width: 6),
                Text(
                  "People on Chat X",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // SHOW ALL USER CONTACTS
            Obx(() {
              final allUsers = userContactController.userList;
              
              var filteredUsers = allUsers.toList();

              // Apply search filter if query is provided
              if (controller.searchQuery.isNotEmpty) {
                filteredUsers = allUsers.where((u) {
                  final query = controller.searchQuery.value.toLowerCase();
                  return u.name.toLowerCase().contains(query) ||
                         u.email.toLowerCase().contains(query);
                }).toList();
              }

              if (userContactController.isLoading.value && allUsers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 56,
                          color: Colors.white38,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No contacts found",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Tap 'New Contact' above to add someone by email",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];

                  return InkWell(
                    onTap: () {
                      Get.to(() => ChatScreen(user: user));
                    },
                    child: ChatTile(
                      heroTag: "contact_${user.uid}",
                      imageUrl: user.profilePic,
                      name: user.name,
                      lastMessage: user.about.isNotEmpty ? user.about : user.email,
                      lastTime: "",
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showNewContactDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Contact"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(hintText: "Enter email address"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              
              final user = await userContactController.getUserByEmail(email);

              if (!context.mounted) return;
              Navigator.pop(context);
              
              if (user != null) {
                Get.to(() => ChatScreen(user: user));
              } else {
                Get.snackbar("Not Found", "No user found with this email");
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
