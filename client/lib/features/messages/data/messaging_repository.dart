import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_endpoints.dart';
import 'messaging_model.dart';

class MessagingRepository {
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<List<MessageModel>> getMessages() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.messages),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId, // Temporary auth header
        },
      );

      print('Messages response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> messagesJson = data['data'] ?? [];
        return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      // Return empty list for now
      return [];
    }
  }

  Future<void> sendMessage({
    required String recipientID,
    required String content,
    String? propertyID,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse(ApiEndpoints.messages),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId,
        },
        body: jsonEncode({
          'recipient_id': recipientID,
          'content': content,
          'property_id': propertyID,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.notifications),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': userId,
        },
      );

      print('Notifications response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notificationsJson = data['data'] ?? [];
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      // Return empty list for now
      return [];
    }
  }
}
