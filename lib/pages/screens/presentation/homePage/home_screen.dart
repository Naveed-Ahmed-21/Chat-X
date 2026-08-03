import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/profile_controller.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/chat_room_list.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/tabBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controller/chat_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late ProfileController profileController;
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearch = false.obs;
  final RxString searchQuery = "".obs;

  @override
  void initState() {
    super.initState();
    profileController = Get.find<ProfileController>();
    Get.find<ChatController>().markMessagesAsDelivered();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Obx(() => isSearch.value
            ? IconButton(
                onPressed: () {
                  isSearch.value = false;
                  searchController.clear();
                },
                icon: const Icon(Icons.arrow_back),
              )
            : Image.asset(AppImages.appLogo)),
        title: Obx(() => isSearch.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search chats...",
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  // Trigger rebuild or update search query in controller
                },
              )
            : Text("Chat X", style: Theme.of(context).textTheme.headlineSmall)),
        actions: [
          Obx(() => isSearch.value
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: () {
                    isSearch.value = true;
                  },
                  icon: const Icon(Icons.search))),
          IconButton(
            onPressed: () async {
              final controller = Get.find<ProfileController>();
              await controller.getUserDetails();
              Get.toNamed('/profileScreen');
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
        bottom: myTabBar(tabController, context),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Get.toNamed("/contactScreen");
        },
        child: const Icon(Icons.message, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TabBarView(
          controller: tabController,
          children: [
            Obx(() => ChatRoomList(
                  searchQuery: searchQuery.value,
                  onlyGroups: false,
                )),
            Obx(() => ChatRoomList(
                  searchQuery: searchQuery.value,
                  onlyGroups: true,
                )),
            ListView(children: const [ListTile(title: Text("Naveed"))]),
          ],
        ),
      ),
    );
  }
}
