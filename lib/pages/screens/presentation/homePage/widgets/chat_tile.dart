import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../../config/imgepaths.dart';

class ChatTile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String lastMessage;
  final String lastTime;

  const ChatTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.lastMessage,
    required this.lastTime,
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
          Row(
            children: [
              Obx(() {
                return isLoading.value
                    ? CircularProgressIndicator()
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade300,
                        child: ClipOval(
                          child: imageUrl.isEmpty
                              ? Image.asset(
                                  AppImages.male,
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
                                  placeholder: (_, __) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    AppImages.male,
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
                      );
              }),

              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.bodyLarge),

                  const SizedBox(height: 5),
                  Text(
                    lastMessage,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          Text(lastTime, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
