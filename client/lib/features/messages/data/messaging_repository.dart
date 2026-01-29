import 'package:supabase_flutter/supabase_flutter.dart';
import 'messaging_model.dart';

class MessagingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MessageModel>> getMessages() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Fetch messages where user is either sender or recipient
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.${user.id},recipient_id.eq.${user.id}')
          .order('created_at', ascending: false);

      final List<dynamic> messagesJson = response as List<dynamic>;
      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<void> sendMessage({
    required String recipientID,
    required String content,
    String? propertyID,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase.from('messages').insert({
        'sender_id': user.id,
        'recipient_id': recipientID,
        'content': content,
        'property_id': propertyID,
        'is_read': false,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> notificationsJson = response as List<dynamic>;
      return notificationsJson
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Real-time listener for messages
  Stream<List<MessageModel>> watchMessages() {
    final user = _supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) => data.map((json) => MessageModel.fromJson(json)).toList());
  }
}
