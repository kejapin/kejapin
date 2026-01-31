import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

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
          .eq('user_id', userId);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
}
