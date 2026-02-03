import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? route;
  final Map<String, dynamic>? metadata;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.route,
    this.metadata,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
      route: json['route'],
      metadata: json['metadata'],
    );
  }
}

class NotificationsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createNotification({
    required String title,
    required String message,
    required String type,
    String? route,
    String? explicitUserId,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = explicitUserId ?? _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'route': route,
        'metadata': metadata,
        'is_read': false,
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  Future<List<NotificationEntity>> fetchNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final data = response as List<dynamic>;
      return data.map((json) => NotificationEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Stream<List<NotificationEntity>> getNotificationsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data
              .where((n) => n['user_id'] == userId)
              .map((json) => NotificationEntity.fromJson(json))
              .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        });
  }

  Future<void> markAsRead(String id) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false); // Only update unread ones
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
}
