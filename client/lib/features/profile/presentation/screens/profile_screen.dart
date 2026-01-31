import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../data/profile_repository.dart';
import '../../../../core/globals.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileRepo.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final profile = snapshot.data;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.alabaster.withOpacity(0.9),
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.structuralBrown),
                  onPressed: () => rootScaffoldKey.currentState?.openDrawer(),
                ),
                title: Text(
                  'PROFILE & SETTINGS',
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.structuralBrown,
                    letterSpacing: 1.5,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Profile Header
                    Stack(
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: profile?.profilePicture != null
                                ? Image.network(
                                    profile!.profilePicture!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 60, color: Colors.grey),
                                  )
                                : const Icon(Icons.person, size: 60, color: Colors.grey),
                          ),
                        ),
                        if (profile?.isVerified ?? false)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.structuralBrown,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.alabaster, width: 4),
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile != null ? '${profile.firstName} ${profile.lastName}' : 'Sarah Jennings',
                      style: GoogleFonts.workSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.structuralBrown,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.structuralBrown.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.structuralBrown.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profile?.isVerified ?? false ? Icons.verified_user : Icons.person_outline,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            profile?.role ?? 'TENANT',
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Settings List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildSettingsGroup([
                            _buildSettingsTile(
                              icon: Icons.pin_drop,
                              title: 'Life Pins',
                              onTap: () => context.push('/life-pins'),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.lock,
                              title: 'Account Security',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.notifications_active,
                              title: 'Notification Preferences',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.credit_card,
                              title: 'Payment Methods',
                              onTap: () {},
                            ),
                          ]),
                          const SizedBox(height: 24),
                          _buildSettingsGroup([
                            _buildSettingsTile(
                              icon: Icons.support_agent,
                              title: 'Help & Support',
                              onTap: () {},
                            ),
                          ]),
                          
                          const SizedBox(height: 32),
                          
                          // Logout Button
                          TextButton.icon(
                            onPressed: () async {
                              await AuthRepository().logout();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                            icon: Icon(Icons.logout, color: Colors.grey[400], size: 20),
                            label: Text(
                              'Log Out',
                              style: GoogleFonts.workSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          Text(
                            'KEJAPIN V2.5.0 (Supabase)',
                            style: GoogleFonts.workSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300],
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBrown.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.structuralBrown.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.structuralBrown, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.workSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.structuralBrown,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[50],
      indent: 72,
    );
  }
}
