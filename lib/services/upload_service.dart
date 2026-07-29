import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UploadService {

  final Dio dio = Dio();

  Future<String> uploadImage(String filePath) async {
    try {

      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(filePath),
        "uid": FirebaseAuth.instance.currentUser!.uid,
      });

      final response = await dio.post(
        "${ApiConstants.baseUrl}/api/upload/profile",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data["imageUrl"];
      }

      throw Exception("Upload failed");

    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Unable to upload image",
      );
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<String> uploadChatImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(filePath),
        "uid": FirebaseAuth.instance.currentUser!.uid,
      });

      final response = await dio.post(
        "${ApiConstants.baseUrl}/api/upload/chat",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data["imageUrl"];
      }

      throw Exception("Upload failed");
    } on DioException catch (e) {

      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("Error: ${e.message}");

      throw Exception(
        e.response?.data["message"] ??
            "Unable to upload chat image",
      );
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }


  Future<Map<String, dynamic>> uploadVideo(String path) async {
    try {
      final formData = FormData.fromMap({
        "video": await MultipartFile.fromFile(path),
        "uid": FirebaseAuth.instance.currentUser!.uid,
      });

      final response = await dio.post(
        "${ApiConstants.baseUrl}/api/upload/video",
        data: formData,
      );

      if (response.statusCode == 200) {
        return {
          "videoUrl": response.data["videoUrl"],
          "duration": response.data["duration"] ?? 0,
          "thumbnail": response.data["thumbnail"],
        };
      }

      throw Exception("Upload failed");
    } on DioException catch (e) {
      print("STATUS: ${e.response?.statusCode}");
      print("DATA: ${e.response?.data}");
      print("MESSAGE: ${e.message}");

      throw Exception(
        e.response?.data["message"] ??
            "Unable to upload video",
      );
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  Future<String> uploadAudio(String path) async {
    try {
      final formData = FormData.fromMap({
        "audio": await MultipartFile.fromFile(path),
        "uid": FirebaseAuth.instance.currentUser!.uid,
      });

      final response = await dio.post(
        "${ApiConstants.baseUrl}/api/upload/audio",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data["audioUrl"];
      }

      throw Exception("Upload failed");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            "Unable to upload audio",
      );
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

}

class ApiConstants {
  static const baseUrl = "http://10.0.2.2:5000";
}