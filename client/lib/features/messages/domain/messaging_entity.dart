class MessageEntity {
  final String id;
  final String senderID;
  final String recipientID;
  final String? propertyID;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  MessageEntity({
    required this.id,
    required this.senderID,
    required this.recipientID,
    this.propertyID,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });
}

class NotificationEntity {
  final String id;
  final String userID;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.userID,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });
}
