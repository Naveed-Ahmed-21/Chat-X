import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../widgets/media/image_viewer_screen.dart';

import '../../../../../config/imgepaths.dart';

class ChatTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final String heroTag;

  const ChatTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    RxBool isLoading = false.obs;

    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Obx(() {
                  return isLoading.value
                      ? CircularProgressIndicator()
                      : GestureDetector(
                          onTap: () {
                            if (imageUrl.startsWith("http")) {
                              Get.to(
                                () => ImageViewerScreen(
                                  imageUrl: imageUrl,
                                  heroTag: heroTag,
                                ),
                              );
                            }
                          },
                          child: Hero(
                            tag: heroTag,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade300,
                              child: ClipOval(
                                child: imageUrl.isEmpty
                                    ? Image.asset(
                                        isGroup ? AppImages.appLogo : AppImages.male,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      )
                                    : imageUrl.startsWith("http")
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        placeholder: (_, _) => const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, _, _) => Image.asset(
                                          isGroup ? AppImages.appLogo : AppImages.male,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Image.asset(
                                        imageUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        );
                }),

                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const SizedBox(width: 0),
                    Positioned(
                      right: -2,
                      bottom: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.greenAccent : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.bodyLarge),

                      const SizedBox(height: 5),

                      Text(
                        lastMessage,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(lastTime, style: Theme.of(context).textTheme.bodyMedium),
              if (unreadCount > 0)
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
