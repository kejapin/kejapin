import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_map_background.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import 'glass_container.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

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
                  // Menu Items
                  Expanded(
                    child: StreamBuilder<UserProfile>(
                      stream: ProfileRepository().getProfileStream(),
                      builder: (context, snapshot) {
                        final profile = snapshot.data;
                        final String role = profile?.role ?? 'TENANT';
                        final String email = profile?.email ?? '';
                        final isAdmin = email == 'kejapinmail@gmail.com';

                        return ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _DrawerItem(
                              icon: Icons.explore_outlined,
                              title: AppLocalizations.of(context)!.marketplace,
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/marketplace');
                              },
                            ),
                            // Tenant Dashboard (Life-Hub)
                            _DrawerItem(
                              icon: Icons.dashboard_customize_outlined,
                              title: 'My Life-Hub',
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/tenant-dashboard');
                              },
                            ),
                            // Landlord/Agent Dashboard
                            if (role == 'LANDLORD' || role == 'AGENT' || isAdmin)
                              _DrawerItem(
                                icon: Icons.business_center_outlined,
                                title: 'Partner Portal',
                                onTap: () {
                                  Navigator.pop(context);
                                  context.go('/landlord-dashboard');
                                },
                              ),
                            // Admin Dashboard
                            if (isAdmin)
                              _DrawerItem(
                                icon: Icons.admin_panel_settings_outlined,
                                title: 'REWARD Admin',
                                onTap: () {
                                  Navigator.pop(context);
                                  context.go('/admin-dashboard');
                                },
                              ),
                            // Apply to be Landlord
                            if (role == 'TENANT' && !isAdmin)
                              _DrawerItem(
                                icon: Icons.verified_user_outlined,
                                title: AppLocalizations.of(context)!.becomePartner,
                                onTap: () {
                                  Navigator.pop(context);
                                  context.go('/apply-landlord');
                                },
                              ),
                            const Divider(color: Colors.white10),
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
                              title: AppLocalizations.of(context)!.messages,
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/messages');
                              },
                            ),
                            _DrawerItem(
                              icon: Icons.person_outline,
                              title: AppLocalizations.of(context)!.profile,
                              onTap: () {
                                Navigator.pop(context);
                                context.go('/profile');
                              },
                            ),
                            const Divider(color: Colors.white10),
                            _DrawerItem(
                              icon: Icons.language_outlined,
                              title: AppLocalizations.of(context)!.languagePreference,
                              onTap: () {
                                Navigator.pop(context);
                                _showLanguageSelector(context);
                              },
                            ),

                          ],
                        );
                      },
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

  void _showLanguageSelector(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        color: AppColors.structuralBrown,
        opacity: 0.95,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(
              "Select Language",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption(context, "English", const Locale('en'), localeProvider),
            _buildLanguageOption(context, "Kiswahili Sanifu", const Locale('sw'), localeProvider),
            _buildLanguageOption(context, "Kiswahili Kenyan", const Locale('sw', 'KE'), localeProvider),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, Locale locale, LocaleProvider provider) {
    final isSelected = provider.locale == locale;
    return ListTile(
      onTap: () {
        provider.setLocale(locale);
        Navigator.pop(context);
      },
      leading: Icon(
        Icons.check_circle,
        color: isSelected ? AppColors.mutedGold : Colors.transparent,
      ),
      title: Text(
        name,
        style: TextStyle(
          color: isSelected ? AppColors.mutedGold : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? null : const Icon(Icons.language, color: Colors.white24, size: 16),
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
