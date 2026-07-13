import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class  UploadService {

  final Dio dio = Dio();

  Future<String?> uploadFile(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(filePath),
        "uid": FirebaseAuth.instance.currentUser!.uid,
      });

      Response response = await dio.post(
        "http://10.0.2.2:5000/api/upload/profile",
        data: formData,
      );

      print(response.statusCode);
      print(response.data);

      if (response.statusCode == 200) {
        return response.data['imageUrl'];
      } 
      return null;
     
    }  on DioException catch (e) {
      print("Status Code: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("Message: ${e.message}");
      print('Error uploading file: $e');
      // throw Exception('Error uploading file: $e');
      return null;
    }
  }
}