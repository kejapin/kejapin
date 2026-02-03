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
  final String? username;
  final String? bio;
  final bool profileCompleted;

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
    this.username,
    this.bio,
    this.profileCompleted = false,
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
      username: json['username'],
      bio: json['bio'],
      profileCompleted: json['profile_completed'] ?? false,
    );
  }
}

class ProfileRepository {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<UserProfile> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // 1. Fetch from Supabase first (primary source for roles/profile)
      final sbResponse = await supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserProfile.fromJson(sbResponse);
    } catch (e) {
      print('Error fetching from Supabase, attempting Go backend fallback: $e');
      try {
        // 2. Fallback to Go backend
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/auth/profile'),
          headers: {'X-User-ID': user.id},
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return UserProfile.fromJson(data);
        }
        throw Exception('Failed to load profile from all sources');
      } catch (e2) {
        throw Exception('Failed to load profile: $e2');
      }
    }
  }

  Stream<UserProfile> getProfileStream() {
    final user = supabase.auth.currentUser;
    if (user == null) return const Stream.empty();

    return supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((data) => UserProfile.fromJson(data.first));
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? profilePicture,
    String? role,
    String? vStatus,
    bool? isVerified,
    String? username,
    String? bio,
    bool? profileCompleted,
    String? phoneNumber,
    String? nationalId,
    String? kraPin,
    String? businessRole,
    String? companyName,
    String? companyBio,
    String? payoutMethod,
    String? payoutDetails,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (role != null) 'role': role,
      if (vStatus != null) 'v_status': vStatus,
      if (isVerified != null) 'is_verified': isVerified,
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio,
      if (profileCompleted != null) 'profile_completed': profileCompleted,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (nationalId != null) 'national_id': nationalId,
      if (kraPin != null) 'kra_pin': kraPin,
      if (businessRole != null) 'business_role': businessRole,
      if (companyName != null) 'company_name': companyName,
      if (companyBio != null) 'company_bio': companyBio,
      if (payoutMethod != null) 'payout_method': payoutMethod,
      if (payoutDetails != null) 'payout_details': payoutDetails,
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
    String? fullName,
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

    // Create a rich documents map that includes everything as a backup
    final fullMetadata = {
      ...documents,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'national_id': nationalId,
      'kra_pin': kraPin,
      'company_name': companyName,
      'company_bio': companyBio,
      'business_role': businessRole,
      'payout_method': payoutMethod,
      'payout_details': payoutDetails,
    };

    print('🚀 SUBMITTING PARTNER APP: $fullMetadata');

    try {
      // 1. Insert into role_applications table (Supabase)
      await supabase.from('role_applications').insert({
        'user_id': user.id,
        'documents': fullMetadata, // Save everything inside JSON map too!
        'status': 'PENDING',
        'full_name': fullName, 
        'phone_number': phoneNumber,
        'national_id': nationalId,
        'kra_pin': kraPin,
        'company_name': companyName,
        'company_bio': companyBio,
        'business_role': businessRole,
        'payout_method': payoutMethod,
        'payout_details': payoutDetails,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2. Update user table with current profile sync
      await updateProfile(
        vStatus: 'PENDING',
        isVerified: false,
        companyName: companyName,
        companyBio: companyBio,
        nationalId: nationalId,
        kraPin: kraPin,
        businessRole: businessRole,
        payoutMethod: payoutMethod,
        payoutDetails: payoutDetails,
        phoneNumber: phoneNumber,
      );

      // 3. (Optional) Also hit Go backend if parallel sync is needed
      try {
        await http.post(
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
        ).timeout(const Duration(seconds: 5));
      } catch (e) {
        print('Backend sync skipped: $e');
      }
      
    } catch (e) {
      print('DEBUG: ProfileRepository.submitLandlordApplication error: $e');
      throw Exception('Failed to submit application: $e');
    }
  }

  // --- Settings & Security Methods ---

  Future<Map<String, dynamic>> getUserSettings() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    
    try {
      final res = await supabase.from('user_settings').select().eq('user_id', user.id).single();
      return res;
    } catch (e) {
      // If no settings exist yet, create default
      await supabase.from('user_settings').insert({'user_id': user.id});
      return await supabase.from('user_settings').select().eq('user_id', user.id).single();
    }
  }

  Future<void> updateUserSettings(Map<String, dynamic> updates) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await supabase.from('user_settings').update(updates).eq('user_id', user.id);
  }

  // --- Payment Methods ---

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final res = await supabase.from('payment_methods').select().eq('user_id', user.id).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> addPaymentMethod(Map<String, dynamic> data) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await supabase.from('payment_methods').insert({...data, 'user_id': user.id});
  }

  // --- Support ---

  Future<void> createSupportTicket(String subject, String message) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await supabase.from('support_tickets').insert({
      'user_id': user.id,
      'subject': subject,
      'message': message,
      'status': 'OPEN'
    });
  }
}
