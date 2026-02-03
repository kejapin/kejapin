```
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:client/features/marketplace/presentation/widgets/property_bubble.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/messages_repository.dart';
import '../../../../core/globals.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessagesRepository _repository = MessagesRepository();

  @override
  void initState() {
    super.initState();
    _repository.warmupCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.messages,
        showSearch: false,
      ),
      body: Stack(
        children: [
          Column(
            children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchLandlordProperty,
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
          
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: MessagesRepository.cacheVersion,
              builder: (context, version, _) => _buildMessagesList(_repository.getMessagesStream()),
            ),
          ),
            ],
          ),
          const SmartDashboardPanel(currentRoute: '/messages'),
        ],
      ),
    );
  }

  Widget _buildMessagesList(Stream<List<MessageEntity>> stream) {
    return StreamBuilder<List<MessageEntity>>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.structuralBrown));
                    }
                    final messages = snapshot.data ?? [];
                    final Map<String, MessageEntity> latestMessages = {};
                    for (var msg in messages) {
                        if (!latestMessages.containsKey(msg.otherUserId)) {
                            latestMessages[msg.otherUserId] = msg;
                        }
                    }
                    final conversations = latestMessages.values.toList();
                    if (conversations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(AppLocalizations.of(context)!.noMessagesYet, style: GoogleFonts.workSans(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final msg = conversations[index];
                        final timeStr = "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}";
                        return GestureDetector(
                          onTap: () => context.push('/chat', extra: {
                            'otherUserId': msg.otherUserId,
                            'otherUserName': msg.otherUserName,
                            'avatarUrl': msg.otherUserAvatar,
                            'propertyTitle': msg.propertyTitle,
                          }),
                          child: _buildMessageTile(
                            name: msg.otherUserName,
                            time: timeStr,
                            property: msg.propertyTitle ?? AppLocalizations.of(context)!.generalInquiry,
                            message: msg.content,
                            avatarUrl: msg.otherUserAvatar,
                            initials: msg.otherUserName.isNotEmpty ? msg.otherUserName[0] : '?',
                            isUnread: !msg.isRead,
                          ),
                        );
                      },
                    );
                  },
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                  child: ClipOval(
                  child: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? (avatarUrl.toLowerCase().endsWith('.svg') 
                          ? SvgPicture.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Container(
                                color: AppColors.structuralBrown.withOpacity(0.1),
                                child: Center(
                                  child: Text(
                                    initials ?? '',
                                    style: GoogleFonts.workSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.structuralBrown,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.structuralBrown.withOpacity(0.1),
                                child: Center(
                                  child: Text(
                                    initials ?? '',
                                    style: GoogleFonts.workSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.structuralBrown,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.structuralBrown.withOpacity(0.1),
                                child: Center(
                                  child: Text(
                                    initials ?? '',
                                    style: GoogleFonts.workSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.structuralBrown,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                      : Container(
                      : Container(
                          color: AppColors.structuralBrown.withOpacity(0.1),
                          child: Center(
                            child: Text(
                              initials ?? '',
                              style: GoogleFonts.workSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.structuralBrown,
                              ),
                            ),
                          ),
                        ),
                ),
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
