import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_map_background.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/auth/data/auth_repository.dart';
import 'glass_container.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: BorderRadius.zero,
        blur: 40,
        opacity: 0.75, // Frosted glass effect
        color: AppColors.structuralBrown,
        borderColor: AppColors.champagne.withOpacity(0.1),
        child: Stack(
          children: [
             const Positioned.fill(
              child: AnimatedMapBackground(
                animate: true,
                opacity: 0.05,
                patternColor: AppColors.champagne,
                child: SizedBox(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 40,
                              color: AppColors.champagne,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'kejapin',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.champagne,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Don't just list it. Pin it.",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.champagne.withOpacity(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: AppColors.champagne.withOpacity(0.1), height: 1),
                  const SizedBox(height: 16),
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _DrawerItem(
                          icon: Icons.explore_outlined,
                          title: 'Marketplace',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/marketplace');
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.pin_drop_outlined,
                          title: 'Life Pins',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/life-pins');
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.favorite_outline,
                          title: 'Saved',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/saved');
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.message_outlined,
                          title: 'Messages',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/messages');
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.person_outline,
                          title: 'Profile',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/profile');
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                  // Logout Button at bottom
                  Divider(color: AppColors.champagne.withOpacity(0.1), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassContainer(
                      color: AppColors.champagne,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(12),
                      borderColor: AppColors.champagne.withOpacity(0.2),
                      blur: 10,
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppColors.champagne,
                          size: 24,
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.champagne,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () async {
                          await AuthRepository().logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
        ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassContainer(
        color: Colors.black, // Darken items slightly
        opacity: 0.2, 
        borderRadius: BorderRadius.circular(12),
        borderColor: AppColors.champagne.withOpacity(0.1),
        blur: 10,
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(
            icon,
            color: AppColors.champagne,
            size: 24,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.champagne,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: AppColors.champagne.withOpacity(0.5),
            size: 16,
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
