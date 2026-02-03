import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_avatar/random_avatar.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../../../../features/auth/data/auth_repository.dart';
import '../../data/profile_repository.dart';
import '../../../../core/globals.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';

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

  Future<void> _handleProfilePicUpdate() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true, // This ensures it renders ABOVE the bottom nav bar
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.changeProfilePhoto, style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 _buildOption(Icons.upload, AppLocalizations.of(context)!.uploadPhoto, _pickAndUploadImage, modalContext),
                 _buildOption(Icons.face, AppLocalizations.of(context)!.chooseAnimated, _showAvatarPicker, modalContext),
                 _buildOption(Icons.shuffle, AppLocalizations.of(context)!.generateRandom, () {
                     _showRandomAvatarGenerator();
                 }, modalContext),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showRandomAvatarGenerator() {
    // Generate a random seed
    String seed = DateTime.now().toIso8601String();
    
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true, // Allows the modal to size itself properly
        builder: (context) {
            return StatefulBuilder(
                builder: (context, setState) {
                    final svgCode = RandomAvatarString(seed, trBackground: true);
                    
                    return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                 Text(AppLocalizations.of(context)!.randomGenerator, style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
                                const SizedBox(height: 24),
                                Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.structuralBrown.withOpacity(0.1), width: 2),
                                    ),
                                    child: RandomAvatar(
                                      seed,
                                      height: 146,
                                      width: 146,
                                    ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                         TextButton.icon(
                                            onPressed: () {
                                                setState(() {
                                                    seed = DateTime.now().toIso8601String() + 'new';
                                                });
                                            }, 
                                            icon: const Icon(Icons.refresh, color: AppColors.mutedGold),
                                            label: Text(AppLocalizations.of(context)!.regenerate, style: TextStyle(color: AppColors.structuralBrown)),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                                Navigator.pop(context); // Close generator
                                                _uploadGeneratedAvatar(svgCode);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.structuralBrown,
                                                foregroundColor: Colors.white,
                                            ),
                                            child: Text(AppLocalizations.of(context)!.saveThisAvatar),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 16),
                            ],
                        ),
                    );
                }
            );
        }
    );
  }

  Future<void> _uploadGeneratedAvatar(String svgCode) async {
    // Show loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.savingAvatar)),
      );
    }

    try {
      // Upload SVG string as a file
      final fileName = '${Supabase.instance.client.auth.currentUser!.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.svg';
      
      await Supabase.instance.client.storage.from('profile-pics').uploadBinary(
        fileName,
        Uint8List.fromList(utf8.encode(svgCode)),
        fileOptions: const FileOptions(contentType: 'image/svg+xml', cacheControl: '3600', upsert: true),
      );

      final imageUrl = Supabase.instance.client.storage.from('profile-pics').getPublicUrl(fileName);
      await _profileRepo.updateProfile(profilePicture: imageUrl);
      
      setState(() {
        _profileFuture = _profileRepo.getProfile();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.newAvatarGenerated)),
        );
      }
    } catch (e) {
      print('Error generating avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate avatar: $e')),
        );
      }
    }
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap, BuildContext modalContext) {
    return InkWell(
      onTap: () async {
        Navigator.of(modalContext).pop();
        await Future.delayed(const Duration(milliseconds: 300));
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.structuralBrown.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.structuralBrown),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.workSans(fontWeight: FontWeight.w500, color: AppColors.structuralBrown)),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uploadingImage)),
      );
    }

    try {
      await _profileRepo.uploadProfilePicture(File(image.path));
      setState(() {
        _profileFuture = _profileRepo.getProfile();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profilePictureUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  void _showAvatarPicker() {
    final avatars = [
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Genie.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Artist.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Robot.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Cat%20Face.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Vampire.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Genie.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Technologist.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Technologist.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Astronaut.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Astronaut.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Mage.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Mage.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Dog%20Face.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Monkey%20Face.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Unicorn%20Face.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Star-Struck.png',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Text(AppLocalizations.of(context)!.chooseAnAvatar, style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _updateAvatar(avatars[index]);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: avatars[index],
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAvatar(String url) async {
    try {
      await _profileRepo.updateProfile(profilePicture: url);
      setState(() {
        _profileFuture = _profileRepo.getProfile();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.avatarUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      body: Stack(
        children: [
          FutureBuilder<UserProfile>(
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
                      AppLocalizations.of(context)!.profileAndSettings,
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
                              child: ClipOval(
                                child: InkWell(
                                  onTap: _handleProfilePicUpdate,
                                  child: _buildProfileImage(profile),
                                ),
                              ),
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _handleProfilePicUpdate,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.mutedGold,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                       BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  child: const Icon(Icons.edit, color: AppColors.structuralBrown, size: 16),
                                ),
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
                        if (profile?.username != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '@${profile!.username}',
                              style: GoogleFonts.workSans(
                                fontSize: 16,
                                color: AppColors.mutedGold,
                                fontWeight: FontWeight.w500,
                              ),
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
                        
                        const SizedBox(height: 24),
                        
                        // Edit Profile Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final result = await context.push('/profile/edit', extra: profile);
                                if (result == true) {
                                  setState(() {
                                    _profileFuture = _profileRepo.getProfile();
                                  });
                                }
                              },
                              icon: const Icon(Icons.edit_note, size: 20),
                              label: Text(AppLocalizations.of(context)!.editProfile),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.structuralBrown,
                                side: BorderSide(color: AppColors.structuralBrown.withOpacity(0.2)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        
                        // Settings List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildSettingsGroup([
                                _buildSettingsTile(
                                  icon: Icons.pin_drop,
                                  title: AppLocalizations.of(context)!.lifePins,
                                  onTap: () => context.push('/life-pins'),
                                ),
                                _buildDivider(),
                                _buildSettingsTile(
                                  icon: Icons.lock,
                                  title: AppLocalizations.of(context)!.accountSecurity,
                                  onTap: () => context.push('/settings/security'),
                                ),
                                _buildDivider(),
                                _buildSettingsTile(
                                  icon: Icons.notifications_active,
                                  title: AppLocalizations.of(context)!.notificationPreferences,
                                  onTap: () => context.push('/settings/notifications'),
                                ),
                                _buildDivider(),
                                _buildSettingsTile(
                                  icon: Icons.credit_card,
                                  title: AppLocalizations.of(context)!.paymentMethods,
                                  onTap: () => context.push('/settings/payment'),
                                ),
                              ]),
                              const SizedBox(height: 24),
                              _buildSettingsGroup([
                                _buildSettingsTile(
                                  icon: Icons.support_agent,
                                  title: AppLocalizations.of(context)!.helpAndSupport,
                                  onTap: () => context.push('/settings/help'),
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
                                    AppLocalizations.of(context)!.logOut,
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
          const SmartDashboardPanel(currentRoute: '/profile'),
        ],
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
  Widget _buildProfileImage(UserProfile? profile) {
    if (profile == null) return const Icon(Icons.person, size: 60, color: Colors.grey);

    String? imageUrl = profile.profilePicture;
    
    // Fallback logic
    if (imageUrl == null || imageUrl.isEmpty) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
             // Check google
             final avatarUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
             if (avatarUrl != null) {
                 imageUrl = avatarUrl;
             }
        }
    }
    
    // Default avatar if everything else fails
    imageUrl ??= 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Technologist.png';

    if (imageUrl.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        imageUrl,
        fit: BoxFit.cover,
        width: 120, // specific size for consistency
        height: 120,
        placeholderBuilder: (BuildContext context) => const CircularProgressIndicator(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.person, size: 60, color: Colors.grey),
    );
  }
}
