import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<void> downloadFile({
    required String url,
    required String fileName,
    bool isMedia = false,
  }) async {
    try {
      if (url.isEmpty) {
        Get.snackbar("Error", "Download URL is empty");
        return;
      }

      // Show progress dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Downloading..."),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String savePath = "${directory!.path}/$fileName";
      
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            if (kDebugMode) {
              print("${(received / total * 100).toStringAsFixed(0)}%");
            }
          }
        },
      );

      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar(
        "Success",
        "File saved to: $savePath",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Download Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
