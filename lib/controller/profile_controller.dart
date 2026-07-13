import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/services/upload_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class ProfileController extends GetxController {

  final UploadService uploadService = Get.find();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final ImagePicker picker = ImagePicker();


  RxString imagePath = "".obs;
  RxString editingField = "".obs;
  RxBool hasChanges = false.obs;
  RxBool isSaving = false.obs;

  Rxn<UserModel> currentUser = Rxn<UserModel>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController aboutController;



  @override
  void onInit() {
    super.onInit();

    nameController = TextEditingController();
    phoneController = TextEditingController();
    aboutController = TextEditingController();

    getUserDetails();
  }




  Future<void> getUserDetails() async {
    try {
      final doc = await db
          .collection("users")
          .doc(auth.currentUser!.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        currentUser.value = UserModel.fromJson(doc.data()!);
      }

      if (currentUser.value != null) {
        nameController.text = currentUser.value!.name;
        phoneController.text = currentUser.value!.phoneNumber;
        aboutController.text = currentUser.value!.about;
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }


  Future<void> updateProfile() async {
    try {
      isSaving.value = true;

      String profileUrl = currentUser.value?.profilePic ?? "";

      if (imagePath.value.isNotEmpty) {
        final url = await uploadService.uploadFile(imagePath.value);

        if (url != null) {
          profileUrl = url;
        }
      }

      await db.collection("users").doc(auth.currentUser!.uid).update({
        "name": nameController.text.trim(),
        "about": aboutController.text.trim(),
        "phoneNumber": phoneController.text.trim(),
        "profilePic": profileUrl,
      });

      currentUser.value = currentUser.value!.copyWith(
        name: nameController.text.trim(),
        about: aboutController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        profilePic: profileUrl,
      );

      imagePath.value = "";

      editingField.value = "";
      hasChanges.value = false;

      Get.snackbar(
        "Success",
        "Profile Updated Successfully",
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
    );

    if (image == null) return;
      // final compressed = await compressImage(image.path);
      imagePath.value = image.path;
      hasChanges.value = true;

  }

  // Future<String> compressImage(String path) async{
  //   final dir = await getTemporaryDirectory();
  //   final targetPath= "${dir.path}/${DateTime.now().microsecondsSinceEpoch}.jpg";
  //   final result = await FlutterImageCompress.compressAndGetFile(
  //       path,
  //       targetPath,
  //     quality: 70
  //   );
  //
  //   if (result == null){
  //     return path;
  //   }
  //
  //   return result.path;
  // }


  Future<void> showImagePicker() async{
    Get.bottomSheet(
      Material(
          color:Theme.of(Get.context!).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
        ),
        child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Gallery"),
                  onTap: () async{
                    Get.back();
                    await pickImage(
                        ImageSource.gallery
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () async{
                    Get.back();
                    await pickImage(
                        ImageSource.camera
                    );
                  },
                )
              ],
            )
        ),
      )
    );
  }

}