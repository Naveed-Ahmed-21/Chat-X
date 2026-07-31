import 'package:chatx_app/services/download_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

class FileMessageWidget extends StatelessWidget {
  final String fileName;
  final String fileSize;
  final String fileUrl;
  final String localPath;
  final bool isComing;

  const FileMessageWidget({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.fileUrl,
    this.localPath = "",
    this.isComing = false,
  });

  String _formatFileSize(int size) {
    if (size < 1024) return "$size B";
    if (size < 1024 * 1024) return "${(size / 1024).toStringAsFixed(1)} KB";
    return "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    // Try to parse fileSize string if it's a number
    String formattedSize = fileSize;
    try {
      int size = int.parse(fileSize);
      formattedSize = _formatFileSize(size);
    } catch (_) {}

    return InkWell(
      onTap: () async {
        final path = localPath.isNotEmpty ? localPath : fileUrl;
        if (path.isNotEmpty) {
          await OpenFilex.open(path);
        }
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.insert_drive_file, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedSize,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (isComing)
              IconButton(
                onPressed: () {
                  final downloadService = Get.find<DownloadService>();
                  downloadService.downloadFile(
                    url: fileUrl,
                    fileName: fileName,
                  );
                },
                icon: const Icon(Icons.download, size: 20, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}

