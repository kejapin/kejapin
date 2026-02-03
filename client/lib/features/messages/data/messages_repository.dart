import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../marketplace/domain/listing_entity.dart';
import '../../profile/data/profile_repository.dart';
import 'notifications_repository.dart';

class MessageEntity {
  final String id;
  final String content;
  final String type;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? propertyTitle;
  final bool isMe;

  MessageEntity({
    required this.id,
    required this.content,
    this.type = 'text',
    this.metadata,
    required this.isRead,
    required this.createdAt,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.propertyTitle,
    required this.isMe,
  });

  factory MessageEntity.fromRecord(Map<String, dynamic> record, String currentUserId, {Map<String, dynamic>? senderData, Map<String, dynamic>? recipientData, Map<String, dynamic>? propertyData}) {
    final senderId = record['sender_id'];
    final isMe = senderId == currentUserId;
    
    // Use provided data or fallback to record nested objects or cache
    final otherUserMap = isMe 
        ? (recipientData ?? record['recipient'] ?? {}) 
        : (senderData ?? record['sender'] ?? {});
        
    final property = propertyData ?? record['property'];
    
    final firstName = otherUserMap['first_name'] ?? '';
    final lastName = otherUserMap['last_name'] ?? '';
    final username = otherUserMap['username'] ?? '';
    
    String displayName = '$firstName $lastName'.trim();
    if (displayName.isEmpty) {
        displayName = username;
    }
    if (displayName.isEmpty) {
        displayName = 'User';
    }
    final name = displayName;
    
    // Parse metadata safely - it could be a Map or null
    Map<String, dynamic>? parsedMetadata;
    if (record['metadata'] != null) {
      if (record['metadata'] is Map<String, dynamic>) {
        parsedMetadata = record['metadata'] as Map<String, dynamic>;
      } else if (record['metadata'] is Map) {
        parsedMetadata = Map<String, dynamic>.from(record['metadata'] as Map);
      }
    }
    
    return MessageEntity(
      id: record['id'] ?? '',
      content: record['content'] ?? '',
      type: record['type'] ?? 'text',
      metadata: parsedMetadata,
      isRead: record['is_read'] ?? false,
      createdAt: record['created_at'] != null ? DateTime.parse(record['created_at']) : DateTime.now(),
      otherUserId: isMe ? record['recipient_id'] : record['sender_id'],
      otherUserName: name,
      otherUserAvatar: MessagesRepository.ensureFullUrl(otherUserMap['profile_picture']),
      propertyTitle: property != null ? property['title'] : null,
      isMe: isMe,
    );
  }
}

class MessagesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Static cache to store user profiles so real-time streams can look up names
  static final Map<String, Map<String, dynamic>> _userCache = {};
  static final Map<String, Map<String, dynamic>> _propertyCache = {};
  static final Set<String> _pendingProfileFetches = {};
  
  // Notifier to trigger UI rebuilds when cache updates
  static final ValueNotifier<int> cacheVersion = ValueNotifier(0);

  static String? ensureFullUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    
    String url;
    if (path.startsWith('http')) {
      url = path;
    } else {
      url = Supabase.instance.client.storage.from('profile-pics').getPublicUrl(path);
    }
    
    // Fix for Android Emulator accessing localhost Supabase
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost')) {
         url = url.replaceAll('localhost', '10.0.2.2');
      }
      if (url.contains('127.0.0.1')) {
         url = url.replaceAll('127.0.0.1', '10.0.2.2');
      }
      
      if (url.contains('10.0.2.2') && url.startsWith('https://')) {
          url = url.replaceFirst('https://', 'http://');
      }
    }
    
    final finalUrl = Uri.encodeFull(url);
    if (!kReleaseMode) {
      debugPrint('📷 ensureFullUrl: $finalUrl (from "$path")');
    }
    return finalUrl;
  }

  static Map<String, dynamic>? getUserCache(String userId) => _userCache[userId];

  Future<List<MessageEntity>> fetchMessages() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('messages')
          .select('*, sender:sender_id(first_name, last_name, username, profile_picture), recipient:recipient_id(first_name, last_name, username, profile_picture), property:property_id(title)')
          .or('sender_id.eq.${user.id},recipient_id.eq.${user.id}')
          .order('created_at', ascending: false);

      final data = response as List<dynamic>;
      return data.map((e) => MessageEntity.fromRecord(e, user.id)).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Stream<List<MessageEntity>> getMessagesStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);
    
    late StreamController<List<MessageEntity>> controller;
    StreamSubscription? sub;
    List<Map<String, dynamic>> lastData = [];
    
    void emit() {
        if (controller.isClosed) return;
        
        // Filter messages for current user
        final userMessages = lastData.where((m) => 
            m['sender_id'] == user.id || m['recipient_id'] == user.id
        ).toList();

        final entities = userMessages.map((e) {
            final otherId = e['sender_id'] == user.id ? e['recipient_id'] : e['sender_id'];
            
            // Trigger background fetches if needed
            if (!_userCache.containsKey(otherId) && !_pendingProfileFetches.contains(otherId)) {
                _fetchAndCacheUser(otherId);
            }
            if (e['property_id'] != null && !_propertyCache.containsKey(e['property_id'])) {
                _fetchAndCacheProperty(e['property_id']);
            }

            return MessageEntity.fromRecord(
              e, 
              user.id,
              senderData: e['sender_id'] == user.id ? null : _userCache[otherId],
              recipientData: e['recipient_id'] == user.id ? null : _userCache[otherId],
              propertyData: _propertyCache[e['property_id']],
            );
        }).toList();
        
        entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(entities);
    }

    void onCacheChanged() => emit();

    controller = StreamController<List<MessageEntity>>(
      onListen: () {
         sub = _supabase.from('messages').stream(primaryKey: ['id']).listen((data) {
             lastData = data;
             emit();
         });
         cacheVersion.addListener(onCacheChanged);
      },
      onCancel: () {
         sub?.cancel();
         cacheVersion.removeListener(onCacheChanged);
      },
    );
    
    return controller.stream;
  }

  Future<void> _fetchAndCacheUser(String userId) async {
      if (_pendingProfileFetches.contains(userId)) return;
      _pendingProfileFetches.add(userId);
      try {
          final profile = await _supabase.from('users').select('first_name, last_name, username, profile_picture').eq('id', userId).single();
          _userCache[userId] = profile;
          // Notify observers
          cacheVersion.value++;
      } catch (e) {
          print('Error background fetching user profile: $e');
      } finally {
          _pendingProfileFetches.remove(userId);
      }
  }

  Future<void> _fetchAndCacheProperty(String propertyId) async {
      try {
          final prop = await _supabase.from('properties').select('title').eq('id', propertyId).single();
          _propertyCache[propertyId] = prop;
          cacheVersion.value++;
      } catch (e) {
          print('Error background fetching property: $e');
      }
  }

  /// Live stream for a specific conversation
  Stream<List<MessageEntity>> getConversationStream(String otherUserId) {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);
    
    late StreamController<List<MessageEntity>> controller;
    StreamSubscription? sub;
    List<Map<String, dynamic>> lastData = [];

    void emit() {
        if (controller.isClosed) return;
        
        final conversationMessages = lastData.where((m) => 
            (m['sender_id'] == user.id && m['recipient_id'] == otherUserId) ||
            (m['sender_id'] == otherUserId && m['recipient_id'] == user.id)
        ).toList();

        final entities = conversationMessages.map((e) {
            final otherId = e['sender_id'] == user.id ? e['recipient_id'] : e['sender_id'];

            // Ensure we have the user/property in cache
            if (!_userCache.containsKey(otherId) && !_pendingProfileFetches.contains(otherId)) {
                _fetchAndCacheUser(otherId);
            }
            if (e['property_id'] != null && !_propertyCache.containsKey(e['property_id'])) {
                _fetchAndCacheProperty(e['property_id']);
            }

            return MessageEntity.fromRecord(
              e, 
              user.id,
              senderData: e['sender_id'] == user.id ? null : _userCache[otherId],
              recipientData: e['recipient_id'] == user.id ? null : _userCache[otherId],
              propertyData: _propertyCache[e['property_id']],
            );
        }).toList();

        entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(entities);
    }

    void onCacheChanged() => emit();

    controller = StreamController<List<MessageEntity>>(
      onListen: () {
         sub = _supabase.from('messages').stream(primaryKey: ['id']).listen((data) {
             lastData = data;
             emit();
         });
         cacheVersion.addListener(onCacheChanged);
      },
      onCancel: () {
         sub?.cancel();
         cacheVersion.removeListener(onCacheChanged);
      },
    );
    
    return controller.stream;
  }

  /// Helper to warm up the cache with conversation partners
  Future<void> warmupCache() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final messages = await _supabase
        .from('messages')
        .select('sender_id, recipient_id, property_id, sender:sender_id(first_name, last_name, username, profile_picture), recipient:recipient_id(first_name, last_name, username, profile_picture), property:property_id(title)')
        .or('sender_id.eq.${user.id},recipient_id.eq.${user.id}');
    
    for (var m in (messages as List)) {
        if (m['sender'] != null) _userCache[m['sender_id']] = m['sender'];
        if (m['recipient'] != null) _userCache[m['recipient_id']] = m['recipient'];
        if (m['property'] != null) _propertyCache[m['property_id']] = m['property'];
    }
    cacheVersion.value++;
  }

  Future<void> sendMessage({
    required String recipientId,
    required String content,
    String? propertyId,
    String? type,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Send original message with rich content support
    await _supabase.from('messages').insert({
      'sender_id': user.id,
      'recipient_id': recipientId,
      'content': content,
      'property_id': propertyId,
      'type': type ?? 'text',
      'metadata': metadata ?? {},
    });

    // Cross-user Notification: Create notification record for recipient
    // Fetch current user details for the notification
    try {
        final profile = await ProfileRepository().getProfile();
        final senderName = '${profile.firstName} ${profile.lastName}';
        final senderAvatar = profile.profilePicture;

        await NotificationsRepository().createNotification(
            explicitUserId: recipientId,
            title: 'New Message from $senderName',
            message: content,
            type: 'MESSAGE',
            metadata: {
                'sender_id': user.id,
                'sender_avatar': senderAvatar,
            },
            route: '/chat' // App will handle extra data on tap
        );
    } catch (e) {
        print('Error creating message notification: $e');
    }
  }

  Future<void> markConversationAsRead(String otherUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('recipient_id', user.id)
        .eq('sender_id', otherUserId);
  }
}
