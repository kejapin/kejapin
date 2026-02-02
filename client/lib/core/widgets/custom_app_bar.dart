import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/glass_container.dart';
import '../../features/search/presentation/widgets/universal_search_bar.dart';

import '../../features/messages/data/notifications_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../globals.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final bool showNotification;
  final bool showMenu;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.title = 'kejapin',
    this.showSearch = true,
    this.showNotification = true,
    this.showMenu = true,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.onMenuPressed,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isSearchActive = false;
  final NotificationsRepository _notifRepo = NotificationsRepository();
  final ProfileRepository _profileRepo = ProfileRepository();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: GlassContainer(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        blur: 40,
        opacity: 0.75, // Frosted glass effect
        color: AppColors.structuralBrown,
        borderColor: AppColors.champagne.withOpacity(0.1),
        child: Container(),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: _isSearchActive
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.champagne),
              onPressed: () => setState(() => _isSearchActive = false),
            )
          : (widget.showMenu
              ? IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.champagne),
                  onPressed: widget.onMenuPressed ?? () => rootScaffoldKey.currentState?.openDrawer(),
                )
              : null),
      title: _isSearchActive
          ? const UniversalSearchBar()
          : Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 24,
                  color: AppColors.champagne,
                  errorBuilder: (_, __, ___) => const Icon(Icons.home_filled, size: 24, color: AppColors.champagne),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: AppColors.champagne,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
      centerTitle: false,
      actions: [
        if (!_isSearchActive && widget.showSearch)
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.champagne),
            onPressed: () => setState(() => _isSearchActive = true),
          ),
        if (widget.showNotification)
          StreamBuilder<List<NotificationEntity>>(
            stream: _notifRepo.getNotificationsStream(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data?.where((n) => !n.isRead).length ?? 0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.champagne),
                    onPressed: widget.onNotificationPressed ?? () => context.push('/notifications'),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.mutedGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.structuralBrown, width: 1.5),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8),
          child: GestureDetector(
            onTap: widget.onProfilePressed,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.structuralBrown.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<UserProfile>(
                    future: _profileRepo.getProfile(),
                    builder: (context, snapshot) {
                        String? imageUrl;
                        if (snapshot.hasData) {
                             imageUrl = snapshot.data!.profilePicture;
                        }
                        
                        // Fallback logic
                        if (imageUrl == null || imageUrl.isEmpty) {
                            final user = Supabase.instance.client.auth.currentUser;
                            if (user != null) {
                                final avatarUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
                                if (avatarUrl != null) {
                                    imageUrl = avatarUrl;
                                }
                            }
                        }
                        
                        imageUrl ??= 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Technologist.png';

                        if (imageUrl!.toLowerCase().endsWith('.svg')) {
                            return SvgPicture.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                placeholderBuilder: (BuildContext context) => const Icon(Icons.person, size: 20, color: Colors.grey),
                            );
                        }

                        return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(Icons.person, size: 20, color: Colors.grey),
                            errorWidget: (context, url, error) => const Icon(Icons.person, size: 20, color: Colors.grey),
                        );
                    }
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
