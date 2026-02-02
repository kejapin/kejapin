# PROFILE FEATURE BACKUP
# Date: 2026-02-01

## 1. Profile Repository (features/profile/data/profile_repository.dart)
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../core/constants/api_endpoints.dart';

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? profilePicture;
  final bool isVerified;
  final String vStatus;
  final int appAttempts;
  final String? companyName;
  final String? companyBio;
  final String? brandColor;
  final String? nationalId;
  final String? kraPin;
  final String? businessRole;
  final String? payoutMethod;
  final String? payoutDetails;
  final String? phoneNumber;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profilePicture,
    this.isVerified = false,
    this.vStatus = 'PENDING',
    this.appAttempts = 0,
    this.companyName,
    this.companyBio,
    this.brandColor,
    this.nationalId,
    this.kraPin,
    this.businessRole,
    this.payoutMethod,
    this.payoutDetails,
    this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'TENANT',
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
      vStatus: json['v_status'] ?? 'PENDING',
      appAttempts: json['app_attempts'] ?? 0,
      companyName: json['company_name'],
      companyBio: json['company_bio'],
      brandColor: json['brand_color'],
      nationalId: json['national_id'],
      kraPin: json['kra_pin'],
      businessRole: json['business_role'],
      payoutMethod: json['payout_method'],
      payoutDetails: json['payout_details'],
      phoneNumber: json['phone_number'],
    );
  }
}

class ProfileRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<UserProfile> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Try fetching from Go backend first (it has the most recent role/status)
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/profile'),
        headers: {'X-User-ID': user.id},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserProfile.fromJson(data);
      }
      
      // Fallback to Supabase if backend fails
      final sbResponse = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserProfile.fromJson(sbResponse);
    } catch (e) {
      print('Error fetching profile, attempting Supabase fallback: $e');
      try {
        final sbResponse = await supabase.from('users').select().eq('id', user.id).single();
        return UserProfile.fromJson(sbResponse);
      } catch (e2) {
        throw Exception('Failed to load profile');
      }
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? profilePicture,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (profilePicture != null) 'profile_picture': profilePicture,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('users').update(updates).eq('id', user.id);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final fileExt = imageFile.path.split('.').last;
    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    try {
      await supabase.storage.from('profile-pics').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final imageUrl = supabase.storage.from('profile-pics').getPublicUrl(fileName);
      await updateProfile(profilePicture: imageUrl);
      return imageUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<void> submitLandlordApplication({
    required Map<String, dynamic> documents,
    String? companyName,
    String? companyBio,
    String? nationalId,
    String? kraPin,
    String? businessRole,
    String? payoutMethod,
    String? payoutDetails,
    String? phoneNumber,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.verificationApply),
        headers: {
          'Content-Type': 'application/json',
          'X-User-ID': user.id,
        },
        body: json.encode({
          'documents': json.encode(documents),
          'company_name': companyName,
          'company_bio': companyBio,
          'national_id': nationalId,
          'kra_pin': kraPin,
          'business_role': businessRole,
          'payout_method': payoutMethod,
          'payout_details': payoutDetails,
          'phone_number': phoneNumber,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Server error');
      }
      
    } catch (e) {
      print('DEBUG: ProfileRepository.submitLandlordApplication error: $e');
      throw Exception('Failed to submit application: $e');
    }
  }
}
```

## 2. Profile Screen (features/profile/presentation/screens/profile_screen.dart)
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change Profile Photo', style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(Icons.upload, 'Upload Photo', _pickAndUploadImage),
                _buildOption(Icons.face, 'Choose Animated', _showAvatarPicker),
                _buildOption(Icons.shuffle, 'Generate Random', () {
                    // Show a sub-dialog or just generate immediately
                    _showRandomAvatarGenerator();
                }),
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
                                Text('Random Generator', style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
                                const SizedBox(height: 24),
                                Container(
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.structuralBrown.withOpacity(0.1), width: 2),
                                    ),
                                    child: SvgPicture.string(svgCode),
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
                                            label: Text('Regenerate', style: TextStyle(color: AppColors.structuralBrown)),
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                                Navigator.pop(context); // Close generator
                                                Navigator.pop(context); // Close main sheet
                                                _uploadGeneratedAvatar(svgCode);
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.structuralBrown,
                                                foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Save This Avatar'),
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
        const SnackBar(content: Text('Saving avatar...')),
      );
    }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
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
        const SnackBar(content: Text('Uploading image...')),
      );
    }

    try {
      await _profileRepo.uploadProfilePicture(File(image.path));
      setState(() {
        _profileFuture = _profileRepo.getProfile();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
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
          const SnackBar(content: Text('New avatar generated!')),
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

  void _showAvatarPicker() {
    final avatars = [
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Genie.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Artist.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Robot.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Cat%20Face.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Man%20Vampire.png',
      'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Woman%20Genie.png',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Text('Choose an Avatar', style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
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
          const SnackBar(content: Text('Avatar updated!')),
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
```

## 3. Custom App Bar (core/widgets/custom_app_bar.dart)
```dart
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
         // ... (frosted glass)
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        blur: 40,
        opacity: 0.75, 
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
```
