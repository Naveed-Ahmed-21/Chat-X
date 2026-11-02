import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart' hide Response;

import '../controller/user_contact_controller.dart';
import '../pages/screens/presentation/chatPage/chat_screen.dart';
import 'upload_service.dart';

class NotificationService extends GetxService {
  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Dio? dio,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _fcm = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _dio = dio ?? Dio(),
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'chatx_notifications';
  static const String _channelName = 'ChatX notifications';

  final FirebaseMessaging _fcm;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Dio _dio;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  String? _registeredUid;

  Future<NotificationService> init() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_chatx_notification'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    _authSubscription = _auth.authStateChanges().listen((user) {
      unawaited(_handleAuthChanged(user));
    });
    _tokenSubscription = _fcm.onTokenRefresh.listen((token) {
      unawaited(_updateTokenInFirestore(token));
    });

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleNotificationTap(message.data),
    );

    await _saveFcmToken();
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    return this;
  }

  Future<void> _handleAuthChanged(User? user) async {
    final nextUid = user?.uid;
    final previousUid = _registeredUid;
    // A signed-out Firebase session can no longer write the old user's token.
    // AuthController removes it before calling FirebaseAuth.signOut().
    if (user != null && previousUid != null && previousUid != nextUid) {
      await _removeDeviceToken(previousUid);
    }
    _registeredUid = nextUid;
    if (user != null) await _saveFcmToken();
  }

  Future<void> prepareForSignOut() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _removeDeviceToken(uid);
    if (_registeredUid == uid) _registeredUid = null;
  }

  Future<void> _saveFcmToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null && token.isNotEmpty) {
        await _updateTokenInFirestore(token);
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not register the FCM device token.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _updateTokenInFirestore(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _registeredUid = uid;
    } catch (error, stackTrace) {
      developer.log(
        'Could not save the FCM device token.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _removeDeviceToken(String uid) async {
    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) return;
      final update = <String, dynamic>{
        'fcmTokens': FieldValue.arrayRemove([token]),
      };
      final userRef = _firestore.collection('users').doc(uid);
      final userDoc = await userRef.get();
      if (userDoc.data()?['fcmToken'] == token) {
        update['fcmToken'] = FieldValue.delete();
      }
      await userRef.set(update, SetOptions(merge: true));
    } catch (error, stackTrace) {
      developer.log(
        'Could not remove the signed-out device token.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (message.data['kind'] != 'chat_message') return;
    final notification = message.notification;
    if (notification == null) return;

    try {
      await _localNotifications.show(
        id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
        title: notification.title ?? 'ChatX',
        body: notification.body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'New messages and ChatX activity',
            icon: 'ic_chatx_notification',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not display a foreground notification.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _handleNotificationTap(Map<String, dynamic>.from(decoded));
      }
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'Ignoring malformed local notification data.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> data) async {
    final senderId = data['senderId']?.toString();
    if (senderId == null || senderId.isEmpty) return;

    if (!Get.isRegistered<UserContactController>()) return;
    final user = await Get.find<UserContactController>().getUserById(senderId);
    if (user != null) Get.to(() => ChatScreen(user: user));
  }

  Future<void> sendChatPushNotification({
    required String roomId,
    required String body,
  }) async {
    final user = _auth.currentUser;
    final normalizedRoomId = roomId.trim();
    if (user == null || normalizedRoomId.isEmpty) return;

    try {
      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) return;

      final baseUrl = await ApiConstants.getActiveBaseUrl(_dio);
      await _dio.post(
        '$baseUrl/api/notifications/send',
        data: {'roomId': normalizedRoomId, 'body': body},
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not send the chat push notification.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> showProfileSavedNotification() async {
    try {
      await _localNotifications.show(
        id: 7401,
        title: 'Profile saved',
        body: 'Your ChatX profile has been updated.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'New messages and ChatX activity',
            icon: 'ic_chatx_notification',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Could not display the profile saved notification.',
        name: 'NotificationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void onClose() {
    unawaited(_authSubscription?.cancel());
    unawaited(_tokenSubscription?.cancel());
    unawaited(_foregroundSubscription?.cancel());
    unawaited(_openedSubscription?.cancel());
    super.onClose();
  }
}
