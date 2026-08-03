import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/message_status_icon.dart';
import 'package:chatx_app/widgets/message_status.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../widgets/media/audio_message_widget.dart';
import '../../../../../widgets/message_type.dart';
import '../../../mediaPreview/media_viewer_screen.dart';
import '../../../mediaPreview/video_player_screen.dart';
import '../../../../../widgets/media/file_message_widget.dart';
import '../../../../../services/download_service.dart';

class ChatType extends StatefulWidget {
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
  final bool enableHero;
  final String senderName;
  final VoidCallback? onSenderTap;

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
    this.enableHero = true,
    this.senderName = "",
    this.onSenderTap,
  });

  @override
  State<ChatType> createState() => _ChatTypeState();
}

class _ChatTypeState extends State<ChatType> {
  String? downloadedPath;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkDownload();
  }

  Future<void> _checkDownload() async {
    if (widget.messageModel == null) return;
    
    final downloadService = Get.find<DownloadService>();
    String fileName = "";
    
    if (widget.messageModel!.fileName.isNotEmpty) {
      fileName = widget.messageModel!.fileName;
    } else {
       // Fallback filename generation
       if (widget.type == MessageType.image) {
         fileName = "IMG_${widget.messageModel!.id}.jpg";
       } else if (widget.type == MessageType.video) {
         fileName = "VID_${widget.messageModel!.id}.mp4";
       } else if (widget.type == MessageType.audio) {
         fileName = "AUD_${widget.messageModel!.id}.mp3";
       }
    }

    if (fileName.isNotEmpty) {
      downloadedPath = await downloadService.getFilePath(fileName);
    }

    if (mounted) {
      setState(() {
        isChecking = false;
      });
    }
  }

  Future<void> _startDownload() async {
    final downloadService = Get.find<DownloadService>();
    String fileName = widget.messageModel?.fileName ?? "";
    
    if (fileName.isEmpty) {
       if (widget.type == MessageType.image) {
         fileName = "IMG_${widget.messageModel!.id}.jpg";
       } else if (widget.type == MessageType.video) {
         fileName = "VID_${widget.messageModel!.id}.mp4";
       } else if (widget.type == MessageType.audio) {
         fileName = "AUD_${widget.messageModel!.id}.mp3";
       }
    }

    final path = await downloadService.downloadFile(
      url: widget.imageUrl,
      fileName: fileName,
      isMedia: true,
    );

    if (path != null && mounted) {
      setState(() {
        downloadedPath = path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildReactionBubble(BuildContext context) {
      final grouped = <String, int>{};

      for (final emoji in widget.reactions.values) {
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
        crossAxisAlignment: widget.isComing
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity(),

            child: Container(
              padding: widget.imageUrl.isNotEmpty
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: (widget.type == MessageType.image || widget.type == MessageType.video)
                    ? 250 + 8.0 // image width + padding
                    : MediaQuery.sizeOf(context).width / 1.3,
              ),
              decoration: BoxDecoration(
                borderRadius: widget.isComing
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
                crossAxisAlignment: widget.isComing
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (widget.messageModel != null && widget.messageModel!.status == MessageStatus.sending)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Uploading...",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  if (widget.senderName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, left: 5),
                      child: InkWell(
                        onTap: widget.onSenderTap,
                        child: Text(
                          widget.isComing 
                              ? "@${widget.senderName.toLowerCase().replaceAll(' ', '')}"
                              : "@you",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  if (widget.repliedMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: widget.imageUrl.isNotEmpty
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
                            widget.repliedSenderName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            widget.repliedMessage!.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  if (widget.isDeleted)
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
                  else if (widget.type == MessageType.image &&
                      widget.imageUrl.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        if (widget.isComing && downloadedPath == null) {
                          _startDownload();
                          return;
                        }

                        final bool hasValidImageIndex =
                            widget.currentImageIndex >= 0 &&
                            widget.currentImageIndex < widget.imageMessages.length;
                        if (!hasValidImageIndex) return;

                        final activeImageMessages = widget.imageMessages
                            .where((m) => !m.isDeleted)
                            .toList();

                        final newIndex = activeImageMessages.indexOf(
                          widget.imageMessages[widget.currentImageIndex],
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
                      child: Stack(
                        children: [
                          widget.enableHero 
                          ? Hero(
                            tag: widget.heroTag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: (widget.messageModel != null && widget.messageModel!.localPath.isNotEmpty && File(widget.messageModel!.localPath).existsSync())
                                  ? Image.file(
                                      File(widget.messageModel!.localPath),
                                      width: 250,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      width: 250,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => Container(
                                        width: 250,
                                        height: 200,
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(),
                                      ),
                                      errorWidget: (_, _, _) =>
                                          const Icon(Icons.broken_image),
                                    ),
                            ),
                          )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: (widget.messageModel != null && widget.messageModel!.localPath.isNotEmpty && File(widget.messageModel!.localPath).existsSync())
                                  ? Image.file(
                                      File(widget.messageModel!.localPath),
                                      width: 250,
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      width: 250,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => Container(
                                        width: 250,
                                        height: 200,
                                        alignment: Alignment.center,
                                        child: const CircularProgressIndicator(),
                                      ),
                                      errorWidget: (_, _, _) =>
                                          const Icon(Icons.broken_image),
                                    ),
                            ),
                          if (widget.isComing && downloadedPath == null && !isChecking)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black38,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.download, color: Colors.white, size: 20),
                                  onPressed: _startDownload,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.message.isNotEmpty)
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
                            widget.message,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),

                    if (widget.isEdited && widget.message.isNotEmpty)
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
                  ] else if (widget.type == MessageType.video &&
                      widget.imageUrl.isNotEmpty) ...[
                    GestureDetector(
                      onTap: () {
                        if (widget.isComing && downloadedPath == null) {
                          _startDownload();
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VideoPlayerScreen(videoUrl: downloadedPath ?? widget.imageUrl),
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
                                (widget.messageModel != null && widget.messageModel!.localPath.isNotEmpty && File(widget.messageModel!.localPath).existsSync())
                                    ? Image.file(
                                        File(widget.messageModel!.localPath),
                                        width: 250,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      )
                                    : (widget.thumbnail.isNotEmpty || (widget.imageUrl.contains("cloudinary") && widget.imageUrl.contains("/video/upload/")))
                                        ? CachedNetworkImage(
                                            imageUrl: widget.thumbnail.isNotEmpty 
                                              ? widget.thumbnail 
                                              : widget.imageUrl.replaceAll(RegExp(r'\.[^.]+$'), '.jpg'),
                                            width: 250,
                                            height: 180,
                                            fit: BoxFit.cover,
                                            placeholder: (_, _) => Container(
                                              width: 250,
                                              height: 180,
                                              color: Colors.black26,
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget: (_, _, _) => Container(
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
                          if (widget.isComing && downloadedPath == null && !isChecking)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black38,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.download, color: Colors.white, size: 20),
                                  onPressed: _startDownload,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (widget.message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 6,
                          right: 6,
                          top: 8,
                        ),
                        child: Text(widget.message),
                      ),
                  ] else if (widget.type == MessageType.audio) ...[
                    AudioMessageWidget(
                      audioUrl: widget.imageUrl,
                      localPath: downloadedPath ?? widget.messageModel?.localPath,
                      initialDurationMs: widget.messageModel?.duration,
                      isComing: widget.isComing,
                      onDownload: _startDownload,
                    ),
                  ] else if (widget.type == MessageType.file) ...[
                    FileMessageWidget(
                      fileName: widget.messageModel?.fileName ?? "Unknown",
                      fileSize: widget.messageModel?.fileSize.toString() ?? "0",
                      fileUrl: widget.imageUrl,
                      localPath: widget.messageModel?.localPath ?? "",
                      isComing: widget.isComing,
                    ),
                  ] else if (widget.message.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(child: Text(widget.message)),
                        if (widget.isEdited)
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
          if (widget.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3, bottom: 3),
              child: Align(
                alignment: widget.isComing
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: buildReactionBubble(context),
              ),
            ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: widget.isComing
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              widget.isComing
                  ? Text(widget.time, style: Theme.of(context).textTheme.labelMedium)
                  : Row(
                      children: [
                        Text(
                          widget.time,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        if (!widget.isComing) MessageStatusIcon(status: widget.status),
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
