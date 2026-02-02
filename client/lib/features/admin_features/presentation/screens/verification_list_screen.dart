import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';
import '../../data/admin_repository.dart';

class VerificationListScreen extends StatefulWidget {
  const VerificationListScreen({super.key});

  @override
  State<VerificationListScreen> createState() => _VerificationListScreenState();
}

class _VerificationListScreenState extends State<VerificationListScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  late Stream<List<VerificationApplication>> _verificationsStream;

  @override
  void initState() {
    super.initState();
    _verificationsStream = _adminRepo.streamVerificationApplications();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'PARTNER APPLICATIONS', showSearch: false),
      body: Stack(
        children: [
          SafeArea(
            child: StreamBuilder<List<VerificationApplication>>(
              stream: _verificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final apps = snapshot.data ?? [];
                if (apps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No pending applications', style: GoogleFonts.workSans(color: Colors.grey[400])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          opacity: 0.8,
                          child: InkWell(
                            onTap: () async {
                               context.push('/admin/verifications/detail', extra: app);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: _getStatusColor(app.status).withOpacity(0.1),
                                    child: Icon(_getStatusIcon(app.status), color: _getStatusColor(app.status), size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.userFullName ?? 'Unknown User',
                                          style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          app.userEmail ?? 'No email',
                                          style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(app.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          app.status,
                                          style: TextStyle(
                                            color: _getStatusColor(app.status),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(app.createdAt),
                                        style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right, color: Colors.grey[300]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SmartDashboardPanel(currentRoute: '/admin/verifications'),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'VERIFIED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'WARNING': return Colors.orange;
      case 'PENDING': return AppColors.mutedGold;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'VERIFIED': return Icons.verified;
      case 'REJECTED': return Icons.cancel;
      case 'WARNING': return Icons.warning;
      case 'PENDING': return Icons.hourglass_empty;
      default: return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
