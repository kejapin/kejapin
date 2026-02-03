import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportTicket {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;
  final String? userEmail;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    this.userEmail,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'],
      userId: json['user_id'] ?? '',
      subject: json['subject'],
      message: json['message'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      userEmail: json['users']?['email'],
    );
  }
}

class VerificationApplication {
  final String id;
  final String userId;
  final Map<String, dynamic> documents;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final String? userEmail;
  final String? userFullName;
  final Map<String, dynamic>? userDetails;
  final String? phoneNumber;
  final String? nationalId;
  final String? kraPin;
  final String? companyName;
  final String? companyBio;
  final String? payoutMethod;
  final String? payoutDetails;
  final String? businessRole;

  VerificationApplication({
    required this.id,
    required this.userId,
    required this.documents,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.userEmail,
    this.userFullName,
    this.userDetails,
    this.phoneNumber,
    this.nationalId,
    this.kraPin,
    this.companyName,
    this.companyBio,
    this.payoutMethod,
    this.payoutDetails,
    this.businessRole,
  });

  factory VerificationApplication.fromJson(Map<String, dynamic> json) {
    final userMap = json['users'] as Map<String, dynamic>?;
    final String fullName = userMap != null 
        ? '${userMap['first_name'] ?? ''} ${userMap['last_name'] ?? ''}'.trim()
        : 'Unknown User';
    
    dynamic rawDocs = json['documents'];
    Map<String, dynamic> parsedDocs = {};
    
    if (rawDocs is String) {
      try {
        parsedDocs = Map<String, dynamic>.from(jsonDecode(rawDocs));
      } catch (e) {
        print('Error decoding documents string: $e');
      }
    } else if (rawDocs is Map) {
      parsedDocs = Map<String, dynamic>.from(rawDocs);
    }

    return VerificationApplication(
      id: json['id'],
      userId: json['user_id'],
      documents: parsedDocs,
      status: json['status'] ?? 'PENDING',
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
      userEmail: userMap?['email'] ?? json['email'] ?? json['user_email'],
      userFullName: (json['full_name'] as String?)?.isNotEmpty == true 
          ? json['full_name'] 
          : fullName.isEmpty ? 'Unknown User' : fullName,
      userDetails: userMap,
      // Aggressive fallback logic: check Snapshot Col -> Documents JSON -> User Profile
      phoneNumber: json['phone_number'] ?? parsedDocs['phone_number'] ?? userMap?['phone_number'],
      nationalId: json['national_id'] ?? parsedDocs['national_id'] ?? userMap?['national_id'],
      kraPin: json['kra_pin'] ?? parsedDocs['kra_pin'] ?? userMap?['kra_pin'],
      companyName: json['company_name'] ?? parsedDocs['company_name'] ?? userMap?['company_name'],
      companyBio: json['company_bio'] ?? parsedDocs['company_bio'] ?? userMap?['company_bio'],
      payoutMethod: json['payout_method'] ?? parsedDocs['payout_method'] ?? userMap?['payout_method'],
      payoutDetails: json['payout_details'] ?? parsedDocs['payout_details'] ?? userMap?['payout_details'],
      businessRole: json['business_role'] ?? parsedDocs['business_role'] ?? userMap?['business_role'],
    );
  }
}

class AdminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SupportTicket>> getAllSupportTickets() async {
    try {
      final response = await _supabase
          .from('support_tickets')
          .select('*, users(email)')
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => SupportTicket.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching support tickets: $e');
      return [];
    }
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    try {
      await _supabase
          .from('support_tickets')
          .update({'status': status})
          .eq('id', ticketId);
    } catch (e) {
      print('Error updating ticket status: $e');
      throw Exception('Failed to update ticket status');
    }
  }

  Future<List<VerificationApplication>> getAllVerificationApplications() async {
    try {
      final response = await _supabase
          .from('role_applications')
          .select('*, users(*)')
          .order('created_at', ascending: false);
      
      if (response.isNotEmpty) {
        print('DEBUG: First Application Row Keys: ${response.first.keys.toList()}');
        print('DEBUG: First Application Row Data: ${response.first}');
      }
      
      print('DEBUG: Fetched ${response.length} verification applications');
      return (response as List).map((json) => VerificationApplication.fromJson(json)).toList();
    } catch (e) {
      print('DEBUG ERROR: Fetching verification applications failed: $e');
      return [];
    }
  }

  Future<void> updateVerificationStatus({
    required String applicationId,
    required String userId,
    required String status,
    String? adminNotes,
    String? newRole, // Optional: Update user role if approved
  }) async {
    try {
      // 1. Update application status
      await _supabase
          .from('role_applications')
          .update({
            'status': status,
            if (adminNotes != null) 'admin_notes': adminNotes,
          })
          .eq('id', applicationId);

      // 2. Update user table status/role
      final updates = {
        'v_status': status,
        if (status == 'VERIFIED' && newRole != null) 'role': newRole,
        if (status == 'VERIFIED') 'is_verified': true,
      };

      await _supabase.from('users').update(updates).eq('id', userId);

      // 3. Send Notification
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'title': status == 'VERIFIED' ? 'Application Approved!' : 'Verification Update',
        'message': adminNotes ?? 'Your partner application status has been updated to $status.',
        'type': 'SYSTEM',
        'is_read': false,
      });

    } catch (e) {
      print('Error updating verification status: $e');
      throw Exception('Failed to update verification: $e');
    }
  }

  Stream<List<VerificationApplication>> streamVerificationApplications() {
    // Listen for any changes on the role_applications table
    // When a change occurs, we re-fetch the full list with user details
    return _supabase
        .from('role_applications')
        .stream(primaryKey: ['id'])
        .asyncMap((_) => getAllVerificationApplications());
  }
}
