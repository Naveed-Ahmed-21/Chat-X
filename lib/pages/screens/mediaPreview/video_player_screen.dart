import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoController;
  ChewieController? chewieController;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    initializePlayer();
  }

  Future<void> initializePlayer() async {
    videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await videoController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
    );

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Chewie(
          controller: chewieController!,
        ),
      ),
    );
  }
}