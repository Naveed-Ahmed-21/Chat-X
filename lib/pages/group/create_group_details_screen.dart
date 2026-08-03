import 'dart:io';
import 'package:chatx_app/controller/group_chat_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/services/upload_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupDetailsScreen extends StatefulWidget {
  final List<UserModel> members;

  const CreateGroupDetailsScreen({super.key, required this.members});

  @override
  State<CreateGroupDetailsScreen> createState() => _CreateGroupDetailsScreenState();
}

class _CreateGroupDetailsScreenState extends State<CreateGroupDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final GroupController groupController = Get.find<GroupController>();

  final UploadService uploadService = UploadService();

  XFile? image;

  bool loading = false;
  bool isPickingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Group")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: isPickingImage ? null : pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: image != null ? FileImage(File(image!.path)) : null,
                child: image == null ? const Icon(Icons.camera_alt, size: 35) : null,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Group Name",
                prefixIcon: Icon(Icons.group),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: "Group Description",
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : createGroup,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Group"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    if (isPickingImage) return;

    setState(() {
      isPickingImage = true;
    });

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          image = picked;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isPickingImage = false;
        });
      }
    }
  }

  Future<void> createGroup() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    if (name.isEmpty) {
      Get.snackbar("Error", "Please enter a group name");
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      String imageUrl = "";
      if (image != null) {
        imageUrl = await uploadService.uploadChatImage(image!.path);
      }

      final memberIds = widget.members.map((u) => u.uid).toList();

      await groupController.createGroup(
        name: name,
        image: imageUrl,
        members: memberIds,
        description: description,
      );

      Get.offAllNamed("/homeScreen"); // Updated to match pagepaths.dart
      Get.snackbar("Success", "Group created successfully");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }
}
