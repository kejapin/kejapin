import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/data/auth_repository.dart';
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
                      _buildSectionTitle("General Settings"),
                      _buildSettingItem(
                        icon: Icons.notifications_none_outlined,
                        title: "Push Notifications",
                        subtitle: "Manage how we notify you about updates",
                        trailing: Switch(
                          value: _notificationsEnabled,
                          activeColor: AppColors.mutedGold,
                          onChanged: (val) => setState(() => _notificationsEnabled = val),
                        ),
                      ),
                      _buildSettingItem(
                        icon: Icons.language_outlined,
                        title: "Language",
                        subtitle: "Change current app language",
                        onTap: () {},
                      ),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle("Security & Privacy"),
                      _buildSettingItem(
                        icon: Icons.lock_outline,
                        title: "Change Password",
                        onTap: () => context.push('/forgot-password'),
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () {},
                      ),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle("Danger Zone"),
                      _buildSettingItem(
                        icon: Icons.delete_outline,
                        title: "Delete Account",
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
              "Settings",
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
          label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text("Delete Account", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This action is permanent and cannot be undone. All your data will be erased.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Handle account deletion
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
