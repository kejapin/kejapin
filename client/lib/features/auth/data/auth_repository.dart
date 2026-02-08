import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../../../../core/constants/api_endpoints.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', response.user!.id);
      }
      
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthResponse> register(String email, String password, String role) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
        emailRedirectTo: 'io.supabase.kejapin://login-callback/',
      );
      
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final rawNonce = _generateRandomString();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final googleSignIn = GoogleSignIn(
        serverClientId: ApiEndpoints.googleWebClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No ID Token found.');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
        nonce: rawNonce,
      );

      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', response.user!.id);
      }

      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.kejapin://reset-password/',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'io.supabase.kejapin://login-callback/',
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }
  
  User? get currentUser => _supabase.auth.currentUser;
}
