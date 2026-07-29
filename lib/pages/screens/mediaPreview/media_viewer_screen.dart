import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../model/message_model.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<MessageModel> images;
  final int initialIndex;

  const MediaViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController pageController;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${currentIndex + 1} / ${widget.images.length}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Dismissible(
        key: const ValueKey("viewer"),

        direction: DismissDirection.vertical,

        onDismissed: (_) {
          Navigator.pop(context);
        },

        child: PageView.builder(
          controller: pageController,

          itemCount: widget.images.length,

          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          itemBuilder: (_, index) {
            final image = widget.images[index];

            return Center(
              child: Hero(
                tag: image.id,
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(image.mediaUrl),
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 50),
                        SizedBox(height: 10),
                        Text("Image not available", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: widget.images[currentIndex].message.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              child: Text(
                widget.images[currentIndex].message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}
