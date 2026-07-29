import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/message_status_icon.dart';
import 'package:chatx_app/widgets/message_status.dart';
import 'package:flutter/material.dart';

import '../../../../../widgets/message_type.dart';
import '../../../mediaPreview/media_viewer_screen.dart';
import '../../../mediaPreview/video_player_screen.dart';

class ChatType extends StatelessWidget {
  final String message;
  final String imageUrl;
  final String thumbnail;
  final bool isComing;
  final String time;
  final MessageStatus status;
  final MessageModel? repliedMessage;
  final String repliedSenderName;
  final bool isDeleted;
  final bool isEdited;
  final Map<String, dynamic> reactions;
  final String heroTag;
  final List<MessageModel> imageMessages;
  final int currentImageIndex;
  final MessageType type;
  final MessageModel? messageModel;

  const ChatType({
    super.key,
    required this.message,
    required this.type,
    required this.imageUrl,
    this.thumbnail = "",
    required this.isComing,
    required this.time,
    required this.status,
    this.repliedMessage,
    this.repliedSenderName = "",
    required this.isDeleted,
    required this.isEdited,
    required this.reactions,
    required this.heroTag,
    required this.imageMessages,
    required this.currentImageIndex,
    this.messageModel,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildReactionBubble(BuildContext context) {
      final grouped = <String, int>{};

      for (final emoji in reactions.values) {
        grouped[emoji] = (grouped[emoji] ?? 0) + 1;
      }

      return Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: grouped.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 17)),

                    if (entry.value > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Column(
        crossAxisAlignment: isComing
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity(),

            child: Container(
              padding: imageUrl.isNotEmpty
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width / 1.3,
              ),
              decoration: BoxDecoration(
                borderRadius: isComing
                    ? BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(0),
                      ),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: isComing
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (repliedMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: imageUrl.isNotEmpty
                          ? const EdgeInsets.all(4)
                          : const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            repliedSenderName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            repliedMessage!.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  if (isDeleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.block, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          "This message was deleted",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  else if (type == MessageType.image &&
                      imageUrl.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        final bool hasValidImageIndex =
                            currentImageIndex >= 0 &&
                            currentImageIndex < imageMessages.length;
                        if (!hasValidImageIndex) return;

                        final activeImageMessages = imageMessages
                            .where((m) => !m.isDeleted)
                            .toList();

                        final newIndex = activeImageMessages.indexOf(
                          imageMessages[currentImageIndex],
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MediaViewerScreen(
                              images: activeImageMessages,
                              initialIndex: newIndex == -1 ? 0 : newIndex,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag:
                            (currentImageIndex >= 0 &&
                                currentImageIndex < imageMessages.length)
                            ? "${imageMessages[currentImageIndex].id}_$currentImageIndex"
                            : imageUrl,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 250,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 250,
                              height: 200,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            ),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          left: 6,
                          right: 6,
                          bottom: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            message,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),

                    if (isEdited && message.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "(edited)",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ),
                  ] else if (type == MessageType.video &&
                      imageUrl.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VideoPlayerScreen(videoUrl: imageUrl),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                thumbnail.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: thumbnail,
                                        width: 250,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          width: 250,
                                          height: 180,
                                          color: Colors.black26,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          width: 250,
                                          height: 180,
                                          color: Colors.black,
                                          child: const Icon(Icons.videocam,
                                              color: Colors.white54),
                                        ),
                                      )
                                    : Container(
                                        width: 250,
                                        height: 180,
                                        color: Colors.black,
                                        child: const Icon(Icons.videocam, color: Colors.white54),
                                      ),

                                const CircleAvatar(
                                  radius: 28,
                                  child: Icon(Icons.play_arrow, size: 34),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 6,
                          right: 6,
                          top: 8,
                        ),
                        child: Text(message),
                      ),
                  ] else if (message.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(child: Text(message)),
                        if (isEdited)
                          const Padding(
                            padding: EdgeInsets.only(left: 6, top: 6, right: 4),
                            child: Text(
                              "(edited)",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          if (reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 3),
              child: Align(
                alignment: isComing
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: buildReactionBubble(context),
              ),
            ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: isComing
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              isComing
                  ? Text(time, style: Theme.of(context).textTheme.labelMedium)
                  : Row(
                      children: [
                        Text(
                          time,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        if (!isComing) MessageStatusIcon(status: status),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
