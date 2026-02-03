import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/messages_repository.dart';
import '../../domain/message_entity.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;

  const UserInfoScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  // Ideally, fetch full profile here. For now, use passed data + cache.
  
  @override
  Widget build(BuildContext context) {
    // Resolve URL
    final rawUrl = widget.avatarUrl ?? MessagesRepository.getUserCache(widget.userId)?['profile_picture'];
    final effectiveUrl = (rawUrl != null && !rawUrl.startsWith('http')) 
        ? MessagesRepository.ensureFullUrl(rawUrl) 
        : rawUrl;

    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.structuralBrown),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.userInfo,
          style: GoogleFonts.workSans(
            color: AppColors.structuralBrown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar
            Hero(
              tag: 'avatar_${widget.userId}',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: _buildAvatar(effectiveUrl),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.userName,
              style: GoogleFonts.workSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.structuralBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${widget.userId.substring(0, 8)}...',
              style: GoogleFonts.workSans(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.flag_outlined, 
                    title: AppLocalizations.of(context)!.reportUser, 
                    color: Colors.red[400],
                    onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report feature coming soon")));
                    }
                  ),
                  const SizedBox(height: 16),
                  _buildActionTile(
                    icon: Icons.block, 
                    title: AppLocalizations.of(context)!.blockUser, 
                    color: Colors.grey[700],
                    onTap: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Block feature coming soon")));
                    }
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
    if (url == null || url.isEmpty) {
        return CircleAvatar(
          backgroundColor: AppColors.structuralBrown.withOpacity(0.1),
          child: Text(
            widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
            style: GoogleFonts.workSans(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
          ),
        );
    }
    
    final isSvg = url.toLowerCase().endsWith('.svg');
    final isLottie = url.toLowerCase().endsWith('.json');

    return ClipOval(
      child: isSvg 
          ? SvgPicture.network(url, fit: BoxFit.cover)
          : isLottie
              ? Lottie.network(url, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, err) => const Icon(Icons.error),
                ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.structuralBrown).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppColors.structuralBrown, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.structuralBrown,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
