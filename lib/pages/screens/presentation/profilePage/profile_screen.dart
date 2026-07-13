import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/auth_controller.dart';
import 'package:chatx_app/controller/profile_controller.dart';
import 'package:chatx_app/pages/screens/presentation/profilePage/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());

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
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
          
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                          children: [
          
                            SizedBox(height: 10,),
          
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Obx(() {
                                  final user = profileController.currentUser.value;

                                  return CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: profileController.imagePath.value.isNotEmpty
                                        ? FileImage(File(profileController.imagePath.value))
                                        : user?.profilePic.isNotEmpty == true
                                        ? NetworkImage(user!.profilePic)
                                        : null,
                                    child: profileController.imagePath.value.isEmpty &&
                                        (user?.profilePic.isEmpty ?? true)
                                        ? Image.asset(AppImages.male)
                                        : null,
                                  );
                                }),
          
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () async {
                                      // Pick Image
                                      await profileController.showImagePicker();
                                    },
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
          
                            SizedBox(height: 20,),
          
                            Row(
                              children: [
                                Text(
                                  "Personal Info",
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
          
                            SizedBox(height: 10,),
          
                            Obx((){
                              final user = profileController.currentUser.value;
          
                              if (user == null){
                                return Center(
                                    child: const CircularProgressIndicator(),
                                );
                              }
          
                              return Column(
                                children: [
          
                                  Container(
                                    padding : EdgeInsets.symmetric(horizontal:8),
                                    decoration:BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: ProfileTile(
                                      icon: Icons.person,
                                      label: "Name",
                                      controller: profileController.nameController,
                                      fieldName: "name",
                                      editingField: profileController.editingField,
                                      hasChanges: profileController.hasChanges,
                                    ),
                                  ),
          
                                  SizedBox(height: 10,),
          
                                  Container(
                                    padding : EdgeInsets.symmetric(horizontal:8),
                                    decoration:BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: ProfileTile(
                                      icon: Icons.info_outline,
                                      label: "About",
                                      controller: profileController.aboutController,
                                      fieldName: "about",
                                      editingField: profileController.editingField,
                                      hasChanges: profileController.hasChanges,
                                    ),
                                  ),
          
                                  SizedBox(height: 10,),
          
                                  // OR use Like this to show the Email
                                  // Container(
                                  //   padding : EdgeInsets.symmetric(horizontal:8),
                                  //   decoration:BoxDecoration(
                                  //     color: Theme.of(context).colorScheme.surface,
                                  //     borderRadius: BorderRadius.circular(10)
                                  //   ),
                                  //   child:ProfileTile(
                                  //     icon: Icons.email,
                                  //     label: "Email",
                                  //     controller: TextEditingController(
                                  //       text: profileController.currentUser.value?.email ?? "",
                                  //     ),
                                  //     fieldName: "",
                                  //     editingField: profileController.editingField,
                                  //     editable: false,
                                  //   ),
                                  // ),
          
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    padding: EdgeInsets.all(15),
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Icon(Icons.alternate_email),
                                        SizedBox(width: 15,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Email",
                                                  style: Theme.of(context).textTheme.labelMedium,
                                                ),
                                              ],
                                            ),
          
                                            SizedBox(height: 5,),
          
                                            Row(
                                              children: [
                                                Text(
                                                  user.email,
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
          
                                      ],
                                    ),
                                  ),
          
                                  SizedBox(height: 10,),
          
                                  Container(
                                    padding : EdgeInsets.symmetric(horizontal:8),
                                    decoration:BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(10)
                                    ),
                                    child:ProfileTile(
                                      icon: Icons.phone,
                                      label: "Phone",
                                      controller: profileController.phoneController,
                                      fieldName: "phone",
                                      editingField: profileController.editingField,
                                      hasChanges: profileController.hasChanges,
                                    ),
                                  ),
                                ],
                              );
                            }),
          
                            SizedBox(height: 30,),
          
          
                            InkWell(
                              onTap: (){
          
                              },
                              child:Obx(() {
                                if (!(profileController.hasChanges.value ||
                                    profileController.editingField.value.isNotEmpty)) {
                                  return const SizedBox();
                                }
          
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: profileController.isSaving.value
                                        ? null
                                        : () {
                                      profileController.updateProfile();
                                    },
                                    child: profileController.isSaving.value
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.save),
                                              SizedBox(width: 8),
                                              Text("SAVE"),
                                            ],
                                        ),
                                  ),
                                );
                              })
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ),

              SizedBox(height: 20,),

              SizedBox(

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 30,
                    ),
                  ),

                    onPressed: (){
                      Get.defaultDialog(
                        title: "Logout",
                        middleText: "Are sure, you want to logout",
                        textCancel: "cancel",
                        textConfirm: "confirm",
                        cancelTextColor: Colors.white,
                        confirmTextColor: Colors.white,
                        buttonColor: Theme.of(context).colorScheme.primary,
                        onConfirm: () async {
                          Get.back();
                          await authController.logoutUser();
                        }
                      );
                    },
                    icon: const Icon(
                        Icons.logout,
                    ) ,
                    label: const Text(
                        "Logout",
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
