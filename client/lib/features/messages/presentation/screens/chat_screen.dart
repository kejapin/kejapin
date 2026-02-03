import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../data/messages_repository.dart';
import '../widgets/attachment_menu.dart';
import '../widgets/bubbles/property_bubble.dart';
import '../widgets/bubbles/location_bubble.dart';
import '../widgets/bubbles/payment_bubble.dart';
import '../widgets/bubbles/schedule_bubble.dart';
import '../widgets/pickers/property_picker_dialog.dart';
import '../widgets/pickers/payment_request_dialog.dart';
import '../widgets/pickers/schedule_picker_dialog.dart';
import '../widgets/pickers/location_picker_dialog.dart';
import '../widgets/bubbles/image_bubble.dart';
import '../widgets/bubbles/document_bubble.dart';
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
  
  bool _showScrollButton = false;
  int _newMessageCount = 0;
  int _totalMessagesCount = 0;
  StreamSubscription? _messageSubscription;
  MessageEntity? _replyMessage;

  @override
  void initState() {
    super.initState();
    _repository.warmupCache();
    _repository.markConversationAsRead(widget.otherUserId);
    
    _scrollController.addListener(_scrollListener);
    // Listen for new messages only to update the count when scrolled up
    _messageSubscription = _repository.getConversationStream(widget.otherUserId).listen((messages) {
      if (mounted) {
        if (_showScrollButton) {
           final diff = messages.length - _totalMessagesCount;
           if (diff > 0) {
             setState(() => _newMessageCount += diff);
           }
        }
        _totalMessagesCount = messages.length;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final isScrolledUp = _scrollController.offset > 200;
      if (isScrolledUp != _showScrollButton) {
        setState(() {
          _showScrollButton = isScrolledUp;
          if (!isScrolledUp) {
            _newMessageCount = 0;
          }
        });
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
     setState(() => _newMessageCount = 0);
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();

    // Check for reply context
    Map<String, dynamic>? metadata;
    if (_replyMessage != null) {
      metadata = {
        'reply_to': {
          'id': _replyMessage!.id,
          'content': _replyMessage!.content,
          'sender': _replyMessage!.isMe ? 'You' : widget.otherUserName,
        }
      };
      setState(() => _replyMessage = null);
    }

    try {
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: content,
        propertyId: widget.propertyId,
        metadata: metadata,
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
          // Background - Image for Mobile, Mesh/Gradient for larger screens
          Positioned.fill(
            child: MediaQuery.of(context).size.width < 600
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      Image.asset(
                        'assets/images/backgrounds/chat_bg_mobile.jpeg',
                        fit: BoxFit.cover,
                      ),
                      // Low opacity overlay
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.structuralBrown.withOpacity(0.75),
                        ),
                      ),
                    ],
                  )
                : kIsWeb
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
          if (_showScrollButton)
            Positioned(
              bottom: 100,
              right: 16,
              child: _buildScrollToBottomButton(),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_replyMessage != null)
             _buildReplyPreview(),
          Row(
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
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
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
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.mutedGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyMessage!.isMe ? 'You' : widget.otherUserName}',
                  style: GoogleFonts.workSans(
                    color: AppColors.mutedGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _replyMessage!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.workSans(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _replyMessage = null),
            icon: const Icon(Icons.close, color: Colors.white54, size: 20),
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
    Widget bubbleContent;
    final isMe = msg.isMe;

    if (msg.type != 'text' && msg.metadata != null) {
      Widget? content;
      switch (msg.type) {
        case 'property':
          content = PropertyBubble(propertyData: msg.metadata!, isMe: isMe);
          break;
        case 'location':
          content = LocationBubble(
            locationName: msg.metadata!['name'] ?? 'Unknown Location',
            latitude: msg.metadata!['latitude']?.toDouble(),
            longitude: msg.metadata!['longitude']?.toDouble(),
            isMe: isMe,
          );
          break;
        case 'payment':
          final amount = msg.metadata!['amount'] is int 
              ? (msg.metadata!['amount'] as int).toDouble() 
              : msg.metadata!['amount'] as double;
          content = PaymentBubble(
            amount: amount, 
            title: msg.metadata!['title'] ?? 'Payment', 
            isMe: isMe
          );
          break;
        case 'schedule':
          content = ScheduleBubble(
            date: DateTime.parse(msg.metadata!['date']), 
            title: msg.metadata!['title'] ?? 'Event', 
            isMe: isMe
          );
          break;
        case 'image':
          content = ImageBubble(
            imageUrl: msg.metadata!['url'] ?? '',
            isMe: isMe,
          );
          break;
        case 'document':
          content = DocumentBubble(
            documentUrl: msg.metadata!['url'] ?? '',
            documentName: msg.metadata!['name'] ?? 'Document',
            isMe: isMe,
          );
          break;
        default:
          break;
      }
      
      if (content != null) {
        bubbleContent = Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [content],
          ),
        );
      } else {
        // Fallback
        bubbleContent = const SizedBox.shrink();
      }
    } else {
      // Text Bubble with Reply Support
      final bubbleColor = isMe 
          ? AppColors.mutedGold 
          : Colors.white.withOpacity(0.15);
      
      bubbleContent = Padding(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.metadata?['reply_to'] != null)
                     _buildReplyQuote(msg.metadata!['reply_to'], isMe),
                  Text(
                    msg.content,
                    style: GoogleFonts.workSans(
                      color: Colors.white, 
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _wrapWithReplyGesture(
      FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: bubbleContent
      ), 
      msg
    );
  }

  Widget _wrapWithReplyGesture(Widget child, MessageEntity msg) {
    return Dismissible(
      key: Key('reply_${msg.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        setState(() => _replyMessage = msg);
        // Optional: Trigger vibration here if haptics package available
        return false;
      },
      background: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: Icon(Icons.reply, color: AppColors.mutedGold),
        ),
      ),
      child: child,
    );
  }

  Widget _buildReplyQuote(Map<String, dynamic> replyData, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: isMe ? Colors.white70 : AppColors.mutedGold, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyData['sender'] ?? 'User',
            style: GoogleFonts.workSans(
              color: isMe ? Colors.white70 : AppColors.mutedGold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyData['content'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.workSans(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
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

  Future<void> _handleAttachmentAction(String id) async {
    try {
      switch (id) {
        case 'gallery':
          await _handleGalleryPick();
          break;
        case 'camera':
          await _handleCameraPick();
          break;
        case 'location':
          await _handleLocationShare();
          break;
        case 'property':
          await _handlePropertyShare();
          break;
        case 'payment':
          await _handlePaymentRequest();
          break;
        case 'schedule':
          await _handleScheduleAppointment();
          break;
        case 'lease':
          await _handleLeaseDocument();
          break;
        case 'repair':
          await _handleRepairRequest();
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$id feature coming soon')),
          );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleGalleryPick() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      await _uploadAndSendImage(image, 'gallery');
    }
  }

  Future<void> _handleCameraPick() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      await _uploadAndSendImage(image, 'camera');
    }
  }

  Future<void> _uploadAndSendImage(XFile image, String source) async {
    // Show inline loading message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Uploading image...'),
          ],
        ),
        duration: Duration(hours: 1), // Will be dismissed manually
      ),
    );

    try {
      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final supabase = Supabase.instance.client;

      // Upload to Supabase Storage
      await supabase.storage
          .from('chat-media')
          .upload('images/$fileName', file);

      final imageUrl = supabase.storage
          .from('chat-media')
          .getPublicUrl('images/$fileName');

      // Send message with image
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: source == 'camera' ? '📷 Sent a photo' : '🖼️ Sent an image',
        propertyId: widget.propertyId,
        type: 'image',
        metadata: {'url': imageUrl, 'source': source},
      );

      // Dismiss loading and show success
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Image sent successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Dismiss loading and show error
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to upload: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLocationShare() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const LocationPickerDialog(),
    );

    if (result != null) {
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: '📍 Shared location: ${result['name']}',
        propertyId: widget.propertyId,
        type: 'location',
        metadata: result,
      );
    }
  }

  Future<void> _handlePropertyShare() async {
    final property = await showDialog(
      context: context,
      builder: (context) => const PropertyPickerDialog(),
    );

    if (property != null) {
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: '🏠 Shared property: ${property.title}',
        propertyId: property.id,
        type: 'property',
        metadata: {
          'title': property.title,
          'price': 'KES ${property.priceAmount.toStringAsFixed(0)}/mo',
          'image': property.photos.isNotEmpty ? property.photos.first : null,
          'id': property.id,
        },
      );
    }
  }

  Future<void> _handlePaymentRequest() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const PaymentRequestDialog(),
    );

    if (result != null) {
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: '💰 Payment request: ${result['title']}',
        propertyId: widget.propertyId,
        type: 'payment',
        metadata: result,
      );
    }
  }

  Future<void> _handleScheduleAppointment() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const SchedulePickerDialog(),
    );

    if (result != null) {
      await _repository.sendMessage(
        recipientId: widget.otherUserId,
        content: '📅 Scheduled: ${result['title']}',
        propertyId: widget.propertyId,
        type: 'schedule',
        metadata: result,
      );
    }
  }

  Future<void> _handleLeaseDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      // Show inline loading message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Uploading document...'),
            ],
          ),
          duration: Duration(hours: 1), // Will be dismissed manually
        ),
      );

      try {
        final file = File(result.files.single.path!);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
        final supabase = Supabase.instance.client;

        await supabase.storage
            .from('chat-media')
            .upload('documents/$fileName', file);

        final fileUrl = supabase.storage
            .from('chat-media')
            .getPublicUrl('documents/$fileName');

        await _repository.sendMessage(
          recipientId: widget.otherUserId,
          content: '📄 Shared document: ${result.files.single.name}',
          propertyId: widget.propertyId,
          type: 'document',
          metadata: {
            'url': fileUrl,
            'name': result.files.single.name,
            'type': 'lease',
          },
        );

        // Dismiss loading and show success
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Document sent successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Dismiss loading and show error
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to upload: $e'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRepairRequest() async {
    // For now, send a simple repair request - can be enhanced with a form
    await _repository.sendMessage(
      recipientId: widget.otherUserId,
      content: '🔧 Repair request submitted',
      propertyId: widget.propertyId,
      type: 'repair',
      metadata: {
        'title': 'Repair Needed',
        'priority': 'medium',
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Repair request sent')),
    );
  }
  Widget _buildScrollToBottomButton() {
    return GestureDetector(
      onTap: _scrollToBottom,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mutedGold,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
            if (_newMessageCount > 0)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _newMessageCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
