import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserProfile> getProfile() async {
    final user = _supabase.auth.currentUser;
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
      final sbResponse = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserProfile.fromJson(sbResponse);
    } catch (e) {
      print('Error fetching profile, attempting Supabase fallback: $e');
      try {
        final sbResponse = await _supabase.from('users').select().eq('id', user.id).single();
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
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (profilePicture != null) 'profile_picture': profilePicture,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await _supabase.from('users').update(updates).eq('id', user.id);
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile');
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
    final user = _supabase.auth.currentUser;
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
