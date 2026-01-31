import 'package:supabase_flutter/supabase_flutter.dart';
import '../../marketplace/domain/listing_entity.dart';

class MessageEntity {
  final String id;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? propertyTitle;

  MessageEntity({
    required this.id,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.propertyTitle,
  });

  factory MessageEntity.fromRecord(Map<String, dynamic> record, String currentUserId) {
    final senderId = record['sender_id'];
    final isMe = senderId == currentUserId;
    
    final otherUser = isMe ? record['recipient'] : record['sender'];
    final property = record['property'];
    
    // Handle cases where relations might be null (though schema says sender/recipient are not null)
    final otherMap = otherUser is Map ? otherUser : {};
    final firstName = otherMap['first_name'] ?? 'Unknown';
    final lastName = otherMap['last_name'] ?? 'User';
    
    return MessageEntity(
      id: record['id'],
      content: record['content'],
      isRead: record['is_read'] ?? false,
      createdAt: DateTime.parse(record['created_at']),
      otherUserId: isMe ? record['recipient_id'] : record['sender_id'],
      otherUserName: '$firstName $lastName',
      otherUserAvatar: otherMap['profile_picture'],
      propertyTitle: property != null ? property['title'] : null,
    );
  }
}

class MessagesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MessageEntity>> fetchMessages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('messages')
          .select('*, sender:sender_id(first_name, last_name, profile_picture), recipient:recipient_id(first_name, last_name, profile_picture), property:property_id(title)')
          .or('sender_id.eq.${user.id},recipient_id.eq.${user.id}')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((e) => MessageEntity.fromRecord(e, user.id)).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<void> sendMessage({
    required String recipientId,
    required String content,
    String? propertyId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('messages').insert({
      'sender_id': user.id,
      'recipient_id': recipientId,
      'content': content,
      'property_id': propertyId,
    });
  }
}
