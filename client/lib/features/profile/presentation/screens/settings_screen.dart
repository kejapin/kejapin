import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/globals.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: kIsWeb
                ? Container(color: AppColors.alabaster)
                : AnimatedMeshGradient(
                    colors: [
                      AppColors.structuralBrown,
                      const Color(0xFF5D4037),
                      AppColors.mutedGold.withOpacity(0.4),
                      AppColors.structuralBrown,
                    ],
                    options: AnimatedMeshGradientOptions(speed: 2),
                  ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildSectionTitle(AppLocalizations.of(context)!.generalSettings),
                      _buildSettingItem(
                        icon: Icons.notifications_none_outlined,
                        title: AppLocalizations.of(context)!.pushNotifications,
                        subtitle: AppLocalizations.of(context)!.manageNotificationsSubtitle,
                        trailing: Switch(
                          value: _notificationsEnabled,
                          activeColor: AppColors.mutedGold,
                          onChanged: (val) => setState(() => _notificationsEnabled = val),
                        ),
                      ),
                      Consumer<LocaleProvider>(
                        builder: (context, provider, child) => _buildSettingItem(
                          icon: Icons.language_outlined,
                          title: AppLocalizations.of(context)!.settings,
                          subtitle: _getLanguageName(provider.locale),
                          onTap: () => _showLanguageSelector(context),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle(AppLocalizations.of(context)!.securityAndPrivacy),
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        title: AppLocalizations.of(context)!.changePassword,
                        onTap: () => context.push('/forgot-password'),
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip_outlined,
                        title: AppLocalizations.of(context)!.privacyPolicy,
                        onTap: () {},
                      ),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle(AppLocalizations.of(context)!.dangerZone),
                      _buildSettingItem(
                        icon: Icons.delete_outline,
                        title: AppLocalizations.of(context)!.deleteAccount,
                        isDestructive: true,
                        onTap: _showDeleteAccountDialog,
                      ),
                      const SizedBox(height: 48),
                      
                      _buildLogoutButton(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => rootScaffoldKey.currentState?.openDrawer(),
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: BorderRadius.circular(12),
              child: const Icon(Icons.menu, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 20),
          FadeInDown(
            child: Text(
              AppLocalizations.of(context)!.settings,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return FadeInLeft(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          padding: EdgeInsets.zero,
          child: ListTile(
            onTap: onTap,
            leading: Icon(
              icon,
              color: isDestructive ? Colors.redAccent : AppColors.mutedGold,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: subtitle != null
                ? Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12))
                : null,
            trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: Colors.white24) : null),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return FadeInUp(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: () async {
            await AuthRepository().logout();
            if (mounted) context.go('/login');
          },
          icon: const Icon(Icons.logout),
          label: Text(AppLocalizations.of(context)!.logOut, style: const TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.structuralBrown,
        title: Text(AppLocalizations.of(context)!.deleteAccount, style: const TextStyle(color: Colors.white)),
        content: Text(
          AppLocalizations.of(context)!.deleteAccountWarning,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              // Handle account deletion
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
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
            Text(AppLocalizations.of(context)!.selectLanguage, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildLanguageOption(context, AppLocalizations.of(context)!.english, const Locale('en'), localeProvider),
            _buildLanguageOption(context, AppLocalizations.of(context)!.kiswahiliSanifu, const Locale('sw'), localeProvider),
            _buildLanguageOption(context, AppLocalizations.of(context)!.kiswahiliKenyan, const Locale('sw', 'KE'), localeProvider),
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
      leading: Icon(Icons.check_circle, color: isSelected ? AppColors.mutedGold : Colors.transparent),
      title: Text(name, style: TextStyle(color: isSelected ? AppColors.mutedGold : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? null : const Icon(Icons.language, color: Colors.white24, size: 16),
    );
  }

  String _getLanguageName(Locale locale) {
    if (locale.languageCode == 'en') return AppLocalizations.of(context)!.english;
    if (locale.languageCode == 'sw') {
      if (locale.countryCode == 'KE') return AppLocalizations.of(context)!.kiswahiliKenyan;
      return AppLocalizations.of(context)!.kiswahiliSanifu;
    }
    return locale.languageCode;
  }
}
