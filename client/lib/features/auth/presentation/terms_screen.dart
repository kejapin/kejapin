import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../../l10n/app_localizations.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.structuralBrown),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '1. Introduction'),
            _buildParagraph(context, 
              'Welcome to Kejapin. These Terms and Conditions govern your use of our website and mobile application. By accessing or using our services, you agree to be bound by these terms. If you disagree with any part of these terms, you may not access the service.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '2. User Accounts'),
            _buildParagraph(context, 
              'When you create an account with us, you must provide accurate, complete, and current information at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account.\n\nYou are responsible for safeguarding the password that you use to access the service and for any activities or actions under your password.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '3. Platform Usage Rules'),
            _buildParagraph(context, 
              'Users agree not to use the platform for any unlawful purpose or in any way that interrupts, damages, or impairs the service. Prohibited activities include but are not limited to:\n\n• Parsing or scraping data from the platform.\n• Listing false or misleading property information.\n• Harassing or abusing other users.\n• Attempting to circumvent security measures.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '4. Privacy Policy'),
            _buildParagraph(context, 
              'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and disclose information about you. By using our Services, you agree that we can use such data in accordance with our privacy policies.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '5. Content and Intellectual Property'),
            _buildParagraph(context, 
              'The service and its original content (excluding Content provided by users), features, and functionality are and will remain the exclusive property of Kejapin and its licensors. The service is protected by copyright, trademark, and other laws.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '6. Termination'),
            _buildParagraph(context, 
              'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '7. Changes to Terms'),
            _buildParagraph(context, 
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days\' notice prior to any new terms taking effect.'
            ),
            const SizedBox(height: 16),

            _buildSectionTitle(context, '8. Contact Us'),
            _buildParagraph(context, 
              'If you have any questions about these Terms, please contact us at support@kejapin.com.'
            ),
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.structuralBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.structuralBrown,
          ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.5,
            ),
      ),
    );
  }
}
