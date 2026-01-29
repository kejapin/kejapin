import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glass_container.dart';

import '../../features/search/presentation/widgets/universal_search_bar.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final bool showNotification;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.title = 'kejapin',
    this.showSearch = true,
    this.showNotification = true,
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: GlassContainer(
        borderRadius: BorderRadius.zero,
        blur: 20,
        opacity: 0.6,
        child: Container(),
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: _isSearchActive
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.structuralBrown),
              onPressed: () => setState(() => _isSearchActive = false),
            )
          : (widget.onMenuPressed != null
              ? IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.structuralBrown),
                  onPressed: widget.onMenuPressed,
                )
              : null),
      title: _isSearchActive
          ? const UniversalSearchBar()
          : Row(
              children: [
                Image.asset('assets/images/logo.png', height: 24, color: AppColors.structuralBrown, errorBuilder: (_,__,___) => const SizedBox()),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: AppColors.structuralBrown,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
      centerTitle: false,
      actions: [
        if (!_isSearchActive && widget.showSearch)
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.structuralBrown),
            onPressed: () => setState(() => _isSearchActive = true),
          ),
        if (widget.showNotification)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.structuralBrown),
                onPressed: widget.onNotificationPressed ?? () => context.push('/notifications'),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.mutedGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.alabaster, width: 1.5),
                  ),
                ),
              ),
            ],
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
                child: const Icon(Icons.person, color: AppColors.structuralBrown),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
