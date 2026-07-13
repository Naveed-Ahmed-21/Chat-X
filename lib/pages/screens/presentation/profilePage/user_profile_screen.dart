import 'package:chatx_app/config/imgepaths.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../model/user_model.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});

  final UserModel user = Get.arguments as UserModel;

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
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: user.profilePic.isNotEmpty
                              ? NetworkImage(user.profilePic)
                              : null,
                          child: user.profilePic.isEmpty
                              ? Image.asset(AppImages.male)
                              : null,
                        ),

                        SizedBox(height: 15),

                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),

                        SizedBox(height: 8),

                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),

                        SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Created At :",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(width: 5,),
                            user.createdAt == ""
                                ? Text(
                                "Not preferred",
                              style: Theme.of(context).textTheme.labelLarge,
                            )
                                : Text(
                                    user.createdAt,
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                          ],
                        ),

                        SizedBox(height: 25.0),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: CupertinoColors.activeGreen,
                                  ),
                                  SizedBox(width: 5),

                                  Text(
                                    "Call",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: CupertinoColors.activeGreen,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.videocam_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),

                                  Text(
                                    "Video",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.wechat_outlined,
                                    color: CupertinoColors.activeBlue,
                                  ),
                                  SizedBox(width: 5),

                                  Text(
                                    "Chat",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: CupertinoColors.activeBlue,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
