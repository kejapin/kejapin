import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/profile/data/profile_repository.dart';
import 'package:client/core/constants/app_colors.dart';
import 'package:client/core/widgets/custom_app_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.helpAndSupport, showSearch: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSupportHeader(context),
            const SizedBox(height: 32),
            _buildFAQSection(context),
            const SizedBox(height: 32),
            _buildContactSection(context),
            const SizedBox(height: 40),
            _buildFooterLinks(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.mutedGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent, size: 48, color: AppColors.mutedGold),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.howCanWeHelp,
            style: GoogleFonts.workSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.structuralBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.findAnswers,
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.frequentlyAskedQuestions,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(AppLocalizations.of(context)!.faq1Question, AppLocalizations.of(context)!.faq1Answer),
        _buildFAQItem(AppLocalizations.of(context)!.faq2Question, AppLocalizations.of(context)!.faq2Answer),
        _buildFAQItem(AppLocalizations.of(context)!.faq3Question, AppLocalizations.of(context)!.faq3Answer),
        _buildFAQItem(AppLocalizations.of(context)!.faq4Question, AppLocalizations.of(context)!.faq4Answer),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w600,
            color: AppColors.structuralBrown,
            fontSize: 14,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: GoogleFonts.workSans(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.contactUs,
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                context,
                Icons.email_outlined,
                AppLocalizations.of(context)!.emailSupport,
                'support@kejapin.com',
                () => _showCreateTicketDialog(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildContactCard(
                context,
                Icons.chat_bubble_outline,
                AppLocalizations.of(context)!.liveChat,
                AppLocalizations.of(context)!.availableHours,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.liveChatOffline)));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.mutedGold, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.workSans(fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.workSans(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: Text(AppLocalizations.of(context)!.termsOfService, style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
        ),
        Text('|', style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
        TextButton(
          onPressed: () {},
          child: Text(AppLocalizations.of(context)!.privacyPolicy, style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
        ),
      ],
    );
  }

  Future<void> _showCreateTicketDialog(BuildContext context) async {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.contactSupport, style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.subject, hintText: AppLocalizations.of(context)!.bookingIssue),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.message, hintText: AppLocalizations.of(context)!.describeIssue),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (messageController.text.isNotEmpty) {
                 try {
                   await ProfileRepository().createSupportTicket(subjectController.text, messageController.text);
                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.ticketCreated)));
                 } catch (e) {
                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                 }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.structuralBrown, foregroundColor: Colors.white),
            child: Text(AppLocalizations.of(context)!.submit),
          ),
        ],
      ),
    );
  }
}
