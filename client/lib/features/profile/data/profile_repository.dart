import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? profilePicture;
  final bool isVerified;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profilePicture,
    this.isVerified = false,
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
}
