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
  });

  factory VerificationApplication.fromJson(Map<String, dynamic> json) {
    final userMap = json['users'] as Map<String, dynamic>?;
    final String fullName = userMap != null 
        ? '${userMap['first_name'] ?? ''} ${userMap['last_name'] ?? ''}'.trim()
        : 'Unknown User';
    
    return VerificationApplication(
      id: json['id'],
      userId: json['user_id'],
      documents: json['documents'] is String ? Map<String, dynamic>.from(Map.castFrom({})) : json['documents'] ?? {},
      status: json['status'] ?? 'PENDING',
      adminNotes: json['admin_notes'],
      createdAt: DateTime.parse(json['created_at']),
      userEmail: userMap?['email'],
      userFullName: fullName.isEmpty ? 'Unknown User' : fullName,
      userDetails: userMap,
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
      
      return (response as List).map((json) => VerificationApplication.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching verification applications: $e');
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
