import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/messages_repository.dart';
import '../widgets/attachment_menu.dart';
import '../widgets/bubbles/property_bubble.dart';
import '../widgets/bubbles/location_bubble.dart';
import '../widgets/bubbles/payment_bubble.dart';
import '../widgets/bubbles/schedule_bubble.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? avatarUrl;
  final String? propertyTitle;
  final String? propertyId;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.avatarUrl,
    this.propertyTitle,
    this.propertyId,
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
    _repository.warmupCache();
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
        propertyId: widget.propertyId,
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
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorSendingMessage}: $e')),
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
          // Background - Mesh or Static Gradient for Web
          Positioned.fill(
            child: kIsWeb
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.structuralBrown,
                          Color(0xFF4E342E),
                          Color(0xFF5D4037),
                          AppColors.structuralBrown,
                        ],
                      ),
                    ),
                  )
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: MessagesRepository.cacheVersion,
                builder: (context, version, _) => _buildAvatar(
                  widget.avatarUrl ?? MessagesRepository.ensureFullUrl(MessagesRepository.getUserCache(widget.otherUserId)?['profile_picture'])
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: GoogleFonts.workSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.propertyTitle != null)
                    Text(
                      widget.propertyTitle!,
                      style: GoogleFonts.workSans(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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

  Widget _buildAvatar(String? url) {
    // Resolve URL if relative and not on web (where it's already resolved in the stream)
    final effectiveUrl = (url != null && !url.startsWith('http')) 
        ? MessagesRepository.ensureFullUrl(url) 
        : url;

    return ClipOval(
      child: effectiveUrl != null && effectiveUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: effectiveUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?', 
                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
              errorWidget: (context, url, error) => Center(
                child: Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?', 
                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
            )
          : Center(
              child: Text(widget.otherUserName.isNotEmpty ? widget.otherUserName[0].toUpperCase() : '?', 
                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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
          IconButton(
            onPressed: () => _showAttachmentMenu(context),
            icon: const Icon(Icons.add_circle, color: AppColors.mutedGold, size: 30),
          ),
          const SizedBox(width: 8),
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
                      hintText: AppLocalizations.of(context)!.typeYourMessage,
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
          Text(AppLocalizations.of(context)!.noMessagesHereYet, style: GoogleFonts.workSans(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChatBubble(MessageEntity msg, int index) {
    final isMe = msg.isMe;
    
    // Check for rich content using type field
    if (msg.type != 'text' && msg.metadata != null) {
      Widget bubbleContent;

      switch (msg.type) {
        case 'property':
          bubbleContent = PropertyBubble(propertyData: msg.metadata!, isMe: isMe);
          break;
        case 'location':
          bubbleContent = LocationBubble(locationName: msg.metadata!['name'] ?? 'Unknown Location', isMe: isMe);
          break;
        case 'payment':
          final amount = msg.metadata!['amount'] is int 
              ? (msg.metadata!['amount'] as int).toDouble() 
              : msg.metadata!['amount'] as double;
          bubbleContent = PaymentBubble(
            amount: amount, 
            title: msg.metadata!['title'] ?? 'Payment', 
            isMe: isMe
          );
          break;
        case 'schedule':
          bubbleContent = ScheduleBubble(
            date: DateTime.parse(msg.metadata!['date']), 
            title: msg.metadata!['title'] ?? 'Event', 
            isMe: isMe
          );
          break;
        default:
          // Unknown type, fallback to text rendering below
          break;
      }

      // Only return early if we successfully created a bubble
      if (msg.type == 'property' || msg.type == 'location' || msg.type == 'payment' || msg.type == 'schedule') {
        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [bubbleContent],
            ),
          ),
        );
      }
    }
    
    // Both mobile (animated mesh) and web (static gradient) are now dark
    final bubbleColor = isMe 
        ? AppColors.mutedGold 
        : Colors.white.withOpacity(0.15);
    
    const textColor = Colors.white;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                   if (isMe) BoxShadow(
                     color: Colors.black.withOpacity(0.1), 
                     blurRadius: 4, 
                     offset: const Offset(0, 2)
                   )
                ],
              ),
              child: Text(
                msg.content,
                style: GoogleFonts.workSans(
                  color: textColor, 
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentMenu(
        onAttachmentSelected: (id) {
          Navigator.pop(context);
          _handleAttachmentAction(id);
        },
      ),
    );
  }

  void _handleAttachmentAction(String id) {
    // Build structured message with type and metadata
    Map<String, dynamic> metadata = {};
    String type = id;

    switch (id) {
      case 'property':
        type = 'property';
        metadata = {
          'title': widget.propertyTitle ?? 'Luxurious Apartment',
          'price': 'KES 45,000/mo',
          'image': 'https://qph.cf2.quoracdn.net/main-qimg-14138122606822216127117600746978.webp'
        };
        break;
      case 'location':
        type = 'location';
        metadata = {'name': 'Westlands Stage, Nairobi'};
        break;
      case 'payment':
        type = 'payment';
        metadata = {'amount': 45000, 'title': 'Rent: October 2024'};
        break;
      case 'schedule':
        type = 'schedule';
        metadata = {
          'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(), 
          'title': 'Viewing Appointment'
        };
        break;
      default:
        // For others, just show a message for now
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$id attachment not yet implemented")),
        );
        return;
    }

    // Generate a user-friendly preview text for the content field
    String contentPreview;
    switch (type) {
      case 'property':
        contentPreview = '🏠 Shared property: ${metadata['title']}';
        break;
      case 'location':
        contentPreview = '📍 Shared location: ${metadata['name']}';
        break;
      case 'payment':
        contentPreview = '💰 Payment request: ${metadata['title']}';
        break;
      case 'schedule':
        contentPreview = '📅 Scheduled: ${metadata['title']}';
        break;
      default:
        contentPreview = 'Shared $type';
    }

    try {
      _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: contentPreview,
        propertyId: widget.propertyId,
        type: type,
        metadata: metadata,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending attachment: $e")),
      );
    }
  }
}
