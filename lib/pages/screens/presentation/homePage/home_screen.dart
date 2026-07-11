import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/controller/profile_controller.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/chat_room_list.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/tabBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{

  final ProfileController profileController = Get.find<ProfileController>();


  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        leading: Image.asset(AppImages.appLogo),
        title: Text(
          "Chat X",
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        actions: [
          IconButton(
              onPressed: (){

              },
              icon: Icon(
                Icons.search
              )
          ),
          IconButton(
              onPressed: () async {
                await profileController.getUserDetails();
                Get.toNamed('/profileScreen');
              },
              icon: Icon(
                  Icons.more_vert
              )
          ),
        ],
        bottom: myTabBar(tabController, context)

      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: (){
            Get.toNamed("/contactScreen");
          },
        child: Icon(
            Icons.message,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TabBarView(
            controller: tabController,
            children: [

              ChatRoomList(),

              ListView(
                children: [
                  ListTile(
                    title: Text("Naveed"),
                  ),
                ],
              ),

              ListView(
                children: [
                  ListTile(
                    title: Text("Ahmed"),
                  ),
                ],
              ),
            ]
        ),
      )
    );
  }
}
