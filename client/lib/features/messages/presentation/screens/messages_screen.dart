import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/messages_repository.dart';
import '../../../auth/data/auth_repository.dart';  // For current user check if needed

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessagesRepository _repository = MessagesRepository();
  List<MessageEntity> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    final messages = await _repository.fetchMessages();
    
    // Group by conversation (otherUserId) and keep only the latest message
    final Map<String, MessageEntity> latestMessages = {};
    for (var msg in messages) {
        // Create a unique key for conversation, e.g., combine user and property or just user
        // For simple chat, just otherUserId is usually enough.
        if (!latestMessages.containsKey(msg.otherUserId)) {
            latestMessages[msg.otherUserId] = msg;
        }
    }
    
    setState(() {
      _conversations = latestMessages.values.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(
        title: 'Messages',
        showSearch: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search landlord, property...',
                hintStyle: GoogleFonts.workSans(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.structuralBrown))
                : _conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              "No messages yet",
                              style: GoogleFonts.workSans(
                                fontSize: 18,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _conversations.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final msg = _conversations[index];
                          // Format time logic could be better (e.g. today/yesterday)
                          final timeStr = "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}";
                          
                          return _buildMessageTile(
                            name: msg.otherUserName,
                            time: timeStr,
                            property: msg.propertyTitle ?? 'General Inquiry',
                            message: msg.content,
                            avatarUrl: msg.otherUserAvatar,
                            initials: msg.otherUserName.isNotEmpty ? msg.otherUserName[0] : '?',
                            isUnread: !msg.isRead, // Need to check if I am the recipient to count as unread
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile({
    required String name,
    required String time,
    required String property,
    required String message,
    String? avatarUrl,
    String? initials,
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.structuralBrown.withOpacity(0.1),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null
                    ? Center(
                        child: Text(
                          initials ?? '',
                          style: GoogleFonts.workSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.structuralBrown,
                          ),
                        ),
                      )
                    : null,
              ),
              if (isUnread)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.structuralBrown,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUnread ? AppColors.mutedGold : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.apartment, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property,
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          color: isUnread ? AppColors.structuralBrown : Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(top: 6, left: 8),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.mutedGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
