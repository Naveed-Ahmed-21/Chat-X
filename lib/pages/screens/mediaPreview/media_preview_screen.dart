import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/chat_controller.dart';
import '../../../controller/media_preview_controller.dart';
import '../../../services/upload_service.dart';
import 'selected_media.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<XFile> files;
  final String receiverId;

  const MediaPreviewScreen({
    super.key,
    required this.files,
    required this.receiverId,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late List<SelectedMedia> media;

  final PageController pageController = PageController();
  final ChatController chatController = Get.find();

  final UploadService uploadService = UploadService();

  final MediaPreviewController controller = Get.put(MediaPreviewController());

  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    media = widget.files.map((e) => SelectedMedia(file: e)).toList();
  }

  @override
  void dispose() {
    pageController.dispose();

    for (final item in media) {
      item.dispose();
    }

    super.dispose();
  }

  Future<void> sendImages() async {

    if (controller.isUploading.value) return;

    controller.isUploading.value = true;

    try {
      for (int i = 0; i < media.length; i++) {
        controller.progress.value = (i + 1) / media.length;

        final imageUrl = await uploadService.uploadChatImage(
          media[i].file.path,
        );
        print(imageUrl);

        await chatController.sendImageMessage(
          receiverId: widget.receiverId,
          imageUrl: imageUrl,
          caption: media[i].captionController.text.trim(),
        );

      }

      controller.isUploading.value = false;

      Get.back();
    } catch (e) {
      controller.isUploading.value = false;

      Get.snackbar("Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Text("${currentPage + 1}/${media.length}"),

        centerTitle: true,
      ),

      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,

            itemCount: media.length,

            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },

            itemBuilder: (_, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.file(
                    File(media[index].file.path),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),

          Obx(() {
            if (!controller.isUploading.value) {
              return const SizedBox();
            }

            return Container(
              color: Colors.black54,

              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const CircularProgressIndicator(),

                    const SizedBox(height: 20),

                    Text(
                      "${(controller.progress.value * 100).toInt()}%",

                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: media[currentPage].captionController,

                  maxLines: 3,

                  minLines: 1,

                  decoration: InputDecoration(
                    hintText: "Add a caption...",

                    filled: true,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Obx(
                () => CircleAvatar(
                  radius: 28,
                  child: IconButton(
                    onPressed: controller.isUploading.value ? null : sendImages,
                    icon: controller.isUploading.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
