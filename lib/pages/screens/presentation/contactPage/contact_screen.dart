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

  void toggleSearch() {
    isSearch.toggle();
  }
}

class ContactScreen extends StatelessWidget {
  ContactScreen({super.key});

  final ContactController controller = Get.put(ContactController());  // For search
  final UserContactController userContactController = Get.find<UserContactController>();
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
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chat X", style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 3),
            Text(
              "Total 234 contacts",
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),

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

          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: ListView(
          children: [
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: controller.isSearch.value
                    ? Container(
                        key: const ValueKey("search"),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => {print(value)},
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search contacts",
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey("empty")),
              );
            }),

            SizedBox(height: 10),

            NewContactTile(
              btnName: 'New Contact',
              icon: Icons.person_add_alt_rounded,
              ontap: () {},
            ),

            SizedBox(height: 10),

            NewContactTile(
              btnName: 'New Group',
              icon: Icons.group_add,
              ontap: () {},
            ),

            SizedBox(height: 10),

            Row(
              children: [
                Image.asset(AppImages.appLogo, scale: 11),

                SizedBox(width: 6),

                Text(
                  "People on Chat X",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),

            SizedBox(height: 10),

            // SHOW ALL USER CONTACTS
            Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userContactController.userList.length,
                itemBuilder: (context, index) {
                  final user = userContactController.userList[index];

                  return InkWell(
                    onTap: () {
                      Get.to(() => ChatScreen(user: user));

                      String roomId = chatRoomController.getRoomId(user.uid);
                      print(roomId);

                    },
                    child: ChatTile(
                      imageUrl: user.profilePic,
                      name: user.name,
                      lastMessage: user.about,
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
}
