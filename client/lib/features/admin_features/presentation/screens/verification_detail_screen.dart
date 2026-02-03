import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/admin_repository.dart';

class VerificationDetailScreen extends StatefulWidget {
  final VerificationApplication application;
  const VerificationDetailScreen({super.key, required this.application});

  @override
  State<VerificationDetailScreen> createState() => _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends State<VerificationDetailScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status, {String? newRole}) async {
    setState(() => _isSubmitting = true);
    try {
      await _adminRepo.updateVerificationStatus(
        applicationId: widget.application.id,
        userId: widget.application.userId,
        status: status,
        adminNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        newRole: newRole,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showActionDialog(String action) {
    String title = "";
    String status = "";
    String? newRole;
    Color color = Colors.blue;

    switch (action) {
      case 'APPROVE_LANDLORD':
        title = "Approve as Landlord";
        status = "VERIFIED";
        newRole = "LANDLORD";
        color = Colors.green;
        break;
      case 'APPROVE_AGENT':
        title = "Approve as Agent";
        status = "VERIFIED";
        newRole = "AGENT";
        color = Colors.green;
        break;
      case 'MORE_TIME':
        title = "Need More Time";
        status = "PENDING";
        color = AppColors.mutedGold;
        break;
      case 'WARNING':
        title = "Send Warning";
        status = "WARNING";
        color = Colors.orange;
        break;
      case 'REJECT':
        title = "Decline Application";
        status = "REJECTED";
        color = Colors.red;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add a custom message or reason for this action (sent to user):"),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Reason/Notes...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(status, newRole: newRole);
            },
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            child: const Text("CONFIRM"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final docs = app.documents;

    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: 'DETAIL: ${app.userFullName}', showSearch: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: _buildSection("User Information", [
                _buildInfoRow("Full Name", app.userFullName ?? 'N/A'),
                _buildInfoRow("Email", app.userEmail ?? 'N/A'),
                _buildInfoRow("Phone", app.phoneNumber ?? 'N/A'),
                _buildInfoRow("National ID", app.nationalId ?? 'N/A'),
                _buildInfoRow("KRA PIN", app.kraPin ?? 'N/A'),
                _buildInfoRow("Business Role", app.businessRole ?? 'N/A'),
              ]),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: _buildSection("Company Details", [
                _buildInfoRow("Company Name", app.companyName ?? 'N/A'),
                _buildInfoRow("Company Bio", app.companyBio ?? 'N/A'),
                _buildInfoRow("Payout Method", app.payoutMethod ?? 'N/A'),
                _buildInfoRow("Payout Details", app.payoutDetails ?? 'N/A'),
              ]),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text("Verification Documents", style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
            ),
            const SizedBox(height: 12),
            _buildGallery(docs),
            const SizedBox(height: 40),
            FadeInUp(
              child: Text("Admin Action", style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
            ),
            const SizedBox(height: 16),
            _isSubmitting 
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildActionButton("APPROVE LANDLORD", Colors.green, () => _showActionDialog('APPROVE_LANDLORD'))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionButton("APPROVE AGENT", Colors.green[700]!, () => _showActionDialog('APPROVE_AGENT'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildActionButton("MORE TIME", AppColors.mutedGold, () => _showActionDialog('MORE_TIME'))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionButton("WARNING", Colors.orange, () => _showActionDialog('WARNING'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton("DECLINE / REJECT", Colors.red, () => _showActionDialog('REJECT')),
                  ],
                ),
            const SizedBox(height: 40),
            // DEBUG SECTION
            Text("Raw Application Data (Debug)", style: GoogleFonts.workSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Text(
                "Phone: ${app.phoneNumber}\n"
                "Nat ID: ${app.nationalId}\n"
                "KRA: ${app.kraPin}\n"
                "Company: ${app.companyName}\n"
                "Payout Details: ${app.payoutDetails}",
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.blueGrey),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)),
        const SizedBox(height: 12),
        GlassContainer(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          opacity: 0.8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.workSans(color: Colors.grey[600], fontSize: 13)),
          Flexible(child: Text(value, style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildGallery(Map<String, dynamic> docs) {
    final List<Map<String, String>> images = [];
    if (docs['id_front'] != null) images.add({'label': 'ID Front', 'url': docs['id_front']});
    if (docs['id_back'] != null) images.add({'label': 'ID Back', 'url': docs['id_back']});
    if (docs['selfie'] != null) images.add({'label': 'Selfie', 'url': docs['selfie']});
    if (docs['proof_document'] != null) images.add({'label': 'Proof Doc', 'url': docs['proof_document']});

    if (images.isEmpty) return Text("No documents found.", style: TextStyle(color: Colors.grey));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final img = images[index];
        return GestureDetector(
          onTap: () => _showFullImage(img['url']!, img['label']!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: img['url']!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(img['label']!, style: GoogleFonts.workSans(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  void _showFullImage(String url, String label) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              ),
            ),
            Positioned(
              top: 10, right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(label, style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
      ),
    );
  }
}
