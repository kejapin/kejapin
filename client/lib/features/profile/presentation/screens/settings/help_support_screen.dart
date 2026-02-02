import 'package:flutter/material.dart';
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
      appBar: CustomAppBar(title: 'HELP & SUPPORT', showSearch: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSupportHeader(),
            const SizedBox(height: 32),
            _buildFAQSection(),
            const SizedBox(height: 32),
            _buildContactSection(context),
            const SizedBox(height: 40),
            _buildFooterLinks(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader() {
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
            'How can we help you?',
            style: GoogleFonts.workSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.structuralBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find answers to common questions or reach out to our team.',
            textAlign: TextAlign.center,
            style: GoogleFonts.workSans(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: GoogleFonts.workSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 16),
        _buildFAQItem('How do I verify my account?', 'Go to the Profile screen and click the "Verify" badge or apply through the "Become a Partner" section.'),
        _buildFAQItem('Is my payment information secure?', 'Yes, we use industry-standard encryption and partner with trusted payment gateways like Stripe/M-Pesa.'),
        _buildFAQItem('Can I cancel a booking?', 'Cancellations depend on the landlord\'s policy. Check the specific listing details for cancellation terms.'),
        _buildFAQItem('How do I contact a landlord?', 'You can message a landlord directly through the "Messages" tab or from their listing page.'),
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
          'CONTACT US',
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
                'Email Support',
                'support@kejapin.com',
                () => _showCreateTicketDialog(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildContactCard(
                context,
                Icons.chat_bubble_outline,
                'Live Chat',
                'Available 9am - 5pm',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live chat agents are currently offline.')));
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

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: Text('Terms of Service', style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
        ),
        Text('|', style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
        TextButton(
          onPressed: () {},
          child: Text('Privacy Policy', style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
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
        title: Text('Contact Support', style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g. Booking Issue'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message', hintText: 'Describe your issue...'),
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
                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticket created. We will email you shortly.')));
                 } catch (e) {
                   if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                 }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.structuralBrown, foregroundColor: Colors.white),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
