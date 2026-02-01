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
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
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
    );
  }
}

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserProfile> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Failed to load profile');
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
