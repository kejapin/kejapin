import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/messages/data/messages_repository.dart';
import 'package:go_router/go_router.dart';
import '../globals.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Track notifications to avoid duplicates in real-time
  final Set<String> _seenNotificationIds = {};

  Future<void> initialize() async {
    // Request permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications for foreground
    if (!const bool.fromEnvironment('dart.library.html')) {
      const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null && details.payload!.isNotEmpty) {
            final context = rootNavigatorKey.currentContext;
            if (context != null) {
              context.push(details.payload!);
            }
          }
        },
      );
    } else {
      // Web specific init if needed, though local_notifications on web is limited
      const initSettings = InitializationSettings(
        android: null, 
        iOS: null,
      );
      await _localNotifications.initialize(settings: initSettings);
    }

    // Get FCM Token
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToSupabase(token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_saveTokenToSupabase);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });

    // Handle background/terminated state click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate based on message data
    });

    // Start listening for app-level notifications if user is already logged in
    if (_supabase.auth.currentUser != null) {
      listenToRealtimeNotifications();
    }
  }

  Future<void> showNotification({required String title, required String body, String? payload}) async {
    const androidDetails = AndroidNotificationDetails(
      'kejapin_local_notifications',
      'Kejapin Alerts',
      channelDescription: 'Notifications for app interactions',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF5D4037), // App's structural brown
    );
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());
    
    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> showChatNotification({
    required String senderId,
    required String senderName,
    required String message,
    String? avatarUrl,
    String? route,
    Map<String, dynamic>? metadata,
  }) async {
    Uint8List? avatarBytes;
    if (avatarUrl != null) {
        avatarBytes = await _getAvatarBytes(avatarUrl);
    }

    final person = Person(
        name: senderName,
        key: senderId,
        icon: (avatarBytes != null && avatarBytes.isNotEmpty) ? ByteArrayAndroidIcon(avatarBytes) : null,
    );

    final messagingStyle = MessagingStyleInformation(
        person,
        conversationTitle: 'New Message',
        groupConversation: false,
        messages: [
            Message(message, DateTime.now(), person),
        ],
    );

    final androidDetails = AndroidNotificationDetails(
      'chat_messages',
      'Chat Messages',
      channelDescription: 'Real-time message notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: messagingStyle,
      icon: '@mipmap/launcher_icon',
      category: AndroidNotificationCategory.message,
      color: const Color(0xFF5D4037),
    );

    final notificationDetails = NotificationDetails(android: androidDetails, iOS: const DarwinNotificationDetails());

    // Prepare payload with metadata for deep linking
    String payload = route ?? '/chat';
    if (!payload.contains('?') && metadata != null) {
      final params = <String, String>{};
      metadata.forEach((k, v) => params[k] = v.toString());
      if (params.isNotEmpty) {
        payload += '?${Uri(queryParameters: params).query}';
      }
    }

    await _localNotifications.show(
      id: senderId.hashCode,
      title: senderName,
      body: message,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  String? _ensureFullUrl(String? path) {
    return MessagesRepository.ensureFullUrl(path);
  }

  Future<Uint8List> _getAvatarBytes(String url) async {
      try {
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
          if (response.statusCode == 200) {
              return response.bodyBytes;
          }
          return Uint8List(0);
      } catch (e) {
          print('Error downloading avatar for notification: $e');
          return Uint8List(0); 
      }
  }

  void listenToRealtimeNotifications() {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .map((data) => data.where((n) => n['user_id'] == userId && n['is_read'] == false))
        .listen((events) {
            for (var event in events) {
                final id = event['id'];
                if (_seenNotificationIds.contains(id)) continue;
                _seenNotificationIds.add(id);

                final type = event['type'];
                final title = event['title'];
                final body = event['message'];

                if (type == 'MESSAGE') {
                    // Support both old (sender_id) and new (otherUserId) keys for robustness
                    final metadata = event['metadata'] ?? {};
                    final senderId = metadata['otherUserId'] ?? metadata['sender_id'] ?? '';
                    final senderName = metadata['otherUserName'] ?? title.replaceAll('New Message from ', '');
                    final avatar = _ensureFullUrl(metadata['avatarUrl'] ?? metadata['sender_avatar']);
                    
                    showChatNotification(
                        senderId: senderId,
                        senderName: senderName,
                        message: body,
                        avatarUrl: avatar,
                        route: event['route'], // Pass route
                        metadata: metadata,
                    );
                } else {
                    showNotification(
                      title: title, 
                      body: body,
                      payload: event['route'],
                    );
                }
            }
        });
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase.from('users').update({'fcm_token': token}).eq('id', userId);
    }
  }
}
