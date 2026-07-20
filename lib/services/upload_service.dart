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
      throw Exception(
        e.response?.data["message"] ??
            "Unable to upload chat image",
      );
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }
}

class ApiConstants {
  static const baseUrl = "http://10.0.2.2:5000";
}