import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/auth_controller.dart';
import 'package:chatx_app/controller/profile_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});

  final AuthController authController = Get.put(AuthController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
            onPressed: (){
              Get.back();
            },
            icon: Icon(
                Icons.arrow_back_ios
            )
        ),
        title: Text(
            "Profile",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 20,),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                        children: [
                          Image.asset(
                              AppImages.male,
                            width: 150,
                          ),

                          SizedBox(height: 10,),

                          Obx(() {
                            return Text(profileController.currentUser.value?.name?? "");
                          }),

                          SizedBox(height: 5,),

                          Obx(() {
                            return Text(profileController.currentUser.value?.email ?? "");
                          }),

                          SizedBox(height: 10,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: CupertinoColors.activeGreen,
                                    ),
                                    SizedBox(width: 5,),

                                    Text(
                                        "Call",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: CupertinoColors.activeGreen,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.videocam_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5,),

                                    Text(
                                      "Video",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.wechat_outlined,
                                      color: CupertinoColors.activeBlue,
                                    ),
                                    SizedBox(width: 5,),

                                    Text(
                                      "Chat",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: CupertinoColors.activeBlue,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )

                        ],
                      )
                  ),
                ],
              ),
            ),
            
            Spacer(),
            
            ElevatedButton(
                onPressed: (){
                  authController.logoutUser();
                }, 
                child: Text("Logout")
            )
            
          ],
        ),
      ),
    );
  }
}
