import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String> _getChatXDirectory() async {
    Directory? baseDir;
    if (Platform.isAndroid) {
      baseDir = Directory('/storage/emulated/0/Download/ChatX');
      if (!await baseDir.exists()) {
        try {
          await baseDir.create(recursive: true);
        } catch (_) {
          baseDir = await getExternalStorageDirectory();
          baseDir = Directory("${baseDir!.path}/ChatX");
          if (!await baseDir.exists()) {
            await baseDir.create(recursive: true);
          }
        }
      }
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      baseDir = Directory("${docDir.path}/ChatX");
      if (!await baseDir.exists()) {
        await baseDir.create(recursive: true);
      }
    }
    return baseDir.path;
  }

  String _getUniqueSavePath(String dirPath, String fileName) {
    String nameWithoutExt = fileName;
    String ext = "";
    final lastDot = fileName.lastIndexOf(".");
    if (lastDot != -1) {
      nameWithoutExt = fileName.substring(0, lastDot);
      ext = fileName.substring(lastDot);
    }

    String candidatePath = "$dirPath/$fileName";
    int counter = 1;
    while (File(candidatePath).existsSync()) {
      candidatePath = "$dirPath/${nameWithoutExt}_$counter$ext";
      counter++;
    }
    return candidatePath;
  }

  Future<bool> isDownloaded(String fileName) async {
    final dir = await _getChatXDirectory();
    final file = File("$dir/$fileName");
    return await file.exists();
  }

  Future<String?> getFilePath(String fileName) async {
    final dir = await _getChatXDirectory();
    final file = File("$dir/$fileName");
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<String?> downloadFile({
    required String url,
    required String fileName,
    bool isMedia = false,
  }) async {
    try {
      if (url.isEmpty) {
        Get.snackbar("Error", "Download URL is empty", snackPosition: SnackPosition.TOP);
        return null;
      }

      // Show progress dialog
      Get.dialog(
        const Center(
          child: Card(
            color: Color(0xFF212338),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                  SizedBox(height: 16),
                  Text("Downloading to ChatX...", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final dir = await _getChatXDirectory();
      final String savePath = _getUniqueSavePath(dir, fileName);

      await _dio.download(
        url,
        savePath,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      // Top-positioned SnackBar banner
      Get.rawSnackbar(
        title: "Success",
        message: "Downloaded successfully to ChatX",
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF6C5CE7),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        mainButton: TextButton(
          onPressed: () {
            OpenFilex.open(savePath);
          },
          child: const Text("OPEN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );

      return savePath;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.rawSnackbar(
        title: "Download Failed",
        message: e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
      );
      return null;
    }
  }
}
