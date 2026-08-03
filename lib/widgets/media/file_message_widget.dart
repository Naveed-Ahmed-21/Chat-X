import 'package:chatx_app/services/download_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

class FileMessageWidget extends StatefulWidget {
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

  @override
  State<FileMessageWidget> createState() => _FileMessageWidgetState();
}

class _FileMessageWidgetState extends State<FileMessageWidget> {
  String? downloadedPath;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkFile();
  }

  Future<void> _checkFile() async {
    final downloadService = Get.find<DownloadService>();
    if (widget.localPath.isNotEmpty) {
      downloadedPath = widget.localPath;
    } else {
      downloadedPath = await downloadService.getFilePath(widget.fileName);
    }
    if (mounted) {
      setState(() {
        isChecking = false;
      });
    }
  }

  String _formatFileSize(int size) {
    if (size < 1024) return "$size B";
    if (size < 1024 * 1024) return "${(size / 1024).toStringAsFixed(1)} KB";
    return "${(size / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    String formattedSize = widget.fileSize;
    try {
      int size = int.parse(widget.fileSize);
      formattedSize = _formatFileSize(size);
    } catch (_) {}

    final bool canOpen = !widget.isComing || downloadedPath != null;

    return InkWell(
      onTap: () async {
        if (canOpen) {
          if (downloadedPath != null) {
            await OpenFilex.open(downloadedPath!);
          } else if (widget.fileUrl.isNotEmpty) {
             await OpenFilex.open(widget.fileUrl);
          }
        } else {
          _startDownload();
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
                    widget.fileName,
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
            if (widget.isComing && downloadedPath == null && !isChecking)
              IconButton(
                onPressed: _startDownload,
                icon: const Icon(Icons.download, size: 20, color: Colors.grey),
              )
            else if (downloadedPath != null)
              const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Future<void> _startDownload() async {
    final downloadService = Get.find<DownloadService>();
    final path = await downloadService.downloadFile(
      url: widget.fileUrl,
      fileName: widget.fileName,
    );
    if (path != null && mounted) {
      setState(() {
        downloadedPath = path;
      });
    }
  }
}
