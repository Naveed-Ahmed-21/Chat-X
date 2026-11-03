import 'package:chatx_app/controller/chat_controller.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/widgets/message_type.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../mediaPreview/media_viewer_screen.dart';
import '../../mediaPreview/video_player_screen.dart';


class SharedAssetsScreen extends StatelessWidget {
  final String roomId;
  final String chatName;

  SharedAssetsScreen({super.key, required this.roomId, required this.chatName});

  final ChatController chatController = Get.find();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF131524),
        appBar: AppBar(
          backgroundColor: const Color(0xFF212338),
          title: Text(chatName),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Media"),
              Tab(text: "Docs"),
              Tab(text: "Links"),
            ],
            indicatorColor: Color(0xFFFF9800),
            labelColor: Color(0xFFFF9800),
            unselectedLabelColor: Colors.white60,
          ),
        ),
        body: StreamBuilder<List<MessageModel>>(
          stream: chatController.getMessages(roomId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No shared items yet", style: TextStyle(color: Colors.white54)));
            }

            final messages = snapshot.data!;

            return TabBarView(
              children: [
                _buildMediaTab(messages),
                _buildDocsTab(messages),
                _buildLinksTab(messages),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMediaTab(List<MessageModel> messages) {
    final mediaMessages = messages.where((m) => m.type == MessageType.image || m.type == MessageType.video).toList();

    if (mediaMessages.isEmpty) {
      return const Center(child: Text("No media shared", style: TextStyle(color: Colors.white54)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: mediaMessages.length,
      itemBuilder: (context, index) {
        final msg = mediaMessages[index];
        return GestureDetector(
          onTap: () {
            if (msg.type == MessageType.image) {
               Get.to(() => MediaViewerScreen(images: [msg], initialIndex: 0));
            } else {
               Get.to(() => VideoPlayerScreen(videoUrl: msg.mediaUrl));
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: msg.type == MessageType.image ? msg.mediaUrl : msg.thumbnail,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.white10),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white24),
              ),
              if (msg.type == MessageType.video)
                const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 30)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocsTab(List<MessageModel> messages) {
    final docsMessages = messages.where((m) => m.type == MessageType.file).toList();

    if (docsMessages.isEmpty) {
      return const Center(child: Text("No documents shared", style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      itemCount: docsMessages.length,
      itemBuilder: (context, index) {
        final msg = docsMessages[index];
        return ListTile(
          leading: const Icon(Icons.insert_drive_file, color: Colors.orange),
          title: Text(msg.fileName.isEmpty ? "Document" : msg.fileName, style: const TextStyle(color: Colors.white)),
          subtitle: Text("${(msg.fileSize / 1024).toStringAsFixed(2)} KB", style: const TextStyle(color: Colors.white54)),
          onTap: () {
            if (msg.mediaUrl.isNotEmpty) {
               launchUrl(Uri.parse(msg.mediaUrl));
            }
          },
        );
      },
    );
  }

  Widget _buildLinksTab(List<MessageModel> messages) {
    final linkRegex = RegExp(r"(https?:\/\/[^\s]+)");
    final List<String> links = [];

    for (var msg in messages) {
      if (msg.type == MessageType.text) {
        final matches = linkRegex.allMatches(msg.message);
        for (var match in matches) {
          links.add(match.group(0)!);
        }
      }
    }

    if (links.isEmpty) {
      return const Center(child: Text("No links shared", style: TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return ListTile(
          leading: const Icon(Icons.link, color: Colors.blue),
          title: Text(link, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () async {
            final uri = Uri.parse(link);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        );
      },
    );
  }
}
