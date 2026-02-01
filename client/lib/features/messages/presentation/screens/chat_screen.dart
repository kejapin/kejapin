import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/messages_repository.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? avatarUrl;
  final String? propertyTitle;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.avatarUrl,
    this.propertyTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _repository = MessagesRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _repository.markConversationAsRead(widget.otherUserId);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    try {
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: content,
      );
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.structuralBrown,
      body: Stack(
        children: [
          // Background - Mesh or Alabaster for Web
          Positioned.fill(
            child: kIsWeb
                ? Container(color: AppColors.alabaster)
                : AnimatedMeshGradient(
                    colors: [
                      AppColors.structuralBrown,
                      const Color(0xFF5D4037),
                      AppColors.mutedGold.withOpacity(0.3),
                      AppColors.structuralBrown,
                    ],
                    options: AnimatedMeshGradientOptions(speed: 1.2),
                  ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: StreamBuilder<List<MessageEntity>>(
                    stream: _repository.getConversationStream(widget.otherUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.mutedGold));
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return _buildEmptyChat();
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildChatBubble(msg, index);
                        },
                      );
                    },
                  ),
                ),
                _buildMessageInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: BorderRadius.circular(24),
        color: Colors.black,
        opacity: 0.25,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 4),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
              child: widget.avatarUrl == null
                  ? Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?', 
                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: GoogleFonts.workSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (widget.propertyTitle != null)
                    Text(
                      widget.propertyTitle!,
                      style: GoogleFonts.workSans(color: Colors.white60, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              height: 56,
              opacity: 0.3,
              blur: 30,
              color: Colors.black, // Dark base for contrast
              borderRadius: BorderRadius.circular(28),
              borderColor: Colors.white.withOpacity(0.1),
              padding: EdgeInsets.zero,
              child: Center(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      selectionColor: AppColors.mutedGold.withOpacity(0.3),
                      selectionHandleColor: AppColors.mutedGold,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    cursorColor: AppColors.mutedGold,
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.2), // Explicitly dark
                      hintText: 'Type your message...',
                      hintStyle: GoogleFonts.workSans(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: AppColors.mutedGold, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: GlassContainer(
              height: 56,
              width: 56,
              color: AppColors.mutedGold,
              opacity: 0.9,
              blur: 10,
              borderRadius: BorderRadius.circular(28),
              borderColor: AppColors.mutedGold.withAlpha(50),
              padding: EdgeInsets.zero,
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          Text("No messages here yet", style: GoogleFonts.workSans(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageEntity msg, int index) {
    final isMe = msg.isMe;
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isMe ? AppColors.mutedGold : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
              bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
               if (isMe) BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: Text(
            msg.content,
            style: GoogleFonts.workSans(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
