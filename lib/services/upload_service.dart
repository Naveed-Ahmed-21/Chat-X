import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const List<String> _debugHosts = [
    'http://10.50.173.11:5000',
    'http://10.50.173.11:5001',
    'http://10.50.173.11:5002',
    'http://10.0.2.2:5000',
    'http://10.0.2.2:5001',
    'http://10.0.2.2:5002',
    'http://localhost:5000',
    'http://localhost:5001',
    'http://localhost:5002',
  ];

  static String? _activeBaseUrl;

  static Future<String> getActiveBaseUrl(Dio dio) async {
    if (_activeBaseUrl != null) return _activeBaseUrl!;

    const configuredUrl = String.fromEnvironment('BASE_URL');
    if (configuredUrl.isNotEmpty) {
      final uri = Uri.tryParse(configuredUrl);
      if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
        throw StateError('BASE_URL must be an absolute backend URL.');
      }
      if (!kDebugMode && uri.scheme != 'https') {
        throw StateError('BASE_URL must use HTTPS outside debug builds.');
      }
      _activeBaseUrl = configuredUrl.replaceFirst(RegExp(r'/+$'), '');
      return _activeBaseUrl!;
    }

    if (!kDebugMode) {
      throw StateError('Configure BASE_URL for non-debug builds.');
    }

    for (final host in _debugHosts) {
      try {
        final response = await dio.get<void>(
          '$host/health',
          options: Options(
            sendTimeout: const Duration(seconds: 1),
            receiveTimeout: const Duration(seconds: 1),
          ),
        );
        if (response.statusCode == 200) {
          _activeBaseUrl = host;
          return host;
        }
      } on DioException {
        // Probe the next development host.
      }
    }

    throw StateError('Could not reach the ChatX development backend.');
  }
}

class UploadService {
  UploadService({Dio? dio, FirebaseAuth? auth})
    : dio = dio ?? Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(minutes: 3),
        ),
      ),
      _auth = auth ?? FirebaseAuth.instance;

  final Dio dio;
  final FirebaseAuth _auth;

  Future<Response<dynamic>> _upload({
    required String endpoint,
    required String field,
    required String path,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Sign in before uploading media.');
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw StateError('Could not authenticate the upload.');
    }

    final baseUrl = await ApiConstants.getActiveBaseUrl(dio);
    final data = FormData.fromMap({
      field: await MultipartFile.fromFile(path),
    });

    return dio.post<dynamic>(
      '$baseUrl$endpoint',
      data: data,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        contentType: 'multipart/form-data',
      ),
    );
  }

  String _requiredString(Response<dynamic> response, String key) {
    final value = response.data is Map ? response.data[key] : null;
    if (response.statusCode != 200 || value is! String || value.isEmpty) {
      throw StateError('The backend returned an invalid upload response.');
    }
    return value;
  }

  Future<String> uploadImage(String filePath) async {
    try {
      final response = await _upload(
        endpoint: '/api/upload/profile',
        field: 'image',
        path: filePath,
      );
      return _requiredString(response, 'imageUrl');
    } catch (error, stackTrace) {
      developer.log(
        'Profile image upload failed.',
        name: 'UploadService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<String> uploadChatImage(String filePath) async {
    try {
      final response = await _upload(
        endpoint: '/api/upload/chat',
        field: 'image',
        path: filePath,
      );
      return _requiredString(response, 'imageUrl');
    } catch (error, stackTrace) {
      developer.log(
        'Chat image upload failed.',
        name: 'UploadService',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadVideo(String path) async {
    final response = await _upload(
      endpoint: '/api/upload/video',
      field: 'video',
      path: path,
    );
    return {
      'videoUrl': _requiredString(response, 'videoUrl'),
      'duration': response.data['duration'] ?? 0,
      'thumbnail': response.data['thumbnail'] ?? '',
    };
  }

  Future<String> uploadAudio(String path) async {
    final response = await _upload(
      endpoint: '/api/upload/audio',
      field: 'audio',
      path: path,
    );
    return _requiredString(response, 'audioUrl');
  }

  Future<Map<String, dynamic>> uploadFile(String path) async {
    final response = await _upload(
      endpoint: '/api/upload/file',
      field: 'file',
      path: path,
    );
    return {
      'fileUrl': _requiredString(response, 'fileUrl'),
      'fileName': response.data['fileName'] ?? 'file',
      'size': response.data['size'] ?? 0,
      'extension': response.data['extension'] ?? '',
    };
  }
}
