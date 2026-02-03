import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/core/constants/app_colors.dart';
import 'package:client/core/widgets/custom_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _twoFactorEnabled = false;
  final User? user = Supabase.instance.client.auth.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.accountSecurity, showSearch: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(AppLocalizations.of(context)!.loginDetails),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context)!.emailAddressLabel,
              value: user?.email ?? AppLocalizations.of(context)!.unknown,
              showEdit: false,
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.lock_reset,
              title: AppLocalizations.of(context)!.changePassword,
              subtitle: AppLocalizations.of(context)!.updatePasswordSecurely,
              onTap: () => context.push('/forgot-password'), // Reusing forgot password flow
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(AppLocalizations.of(context)!.enhancedSecurity),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.mutedGold,
                title: Text(
                  AppLocalizations.of(context)!.twoFactorAuth,
                  style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: AppColors.structuralBrown),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.twoFactorDesc,
                  style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey),
                ),
                value: _twoFactorEnabled,
                onChanged: (val) {
                  setState(() => _twoFactorEnabled = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.twoFactorUpdated)),
                  );
                },
              ),
            ),

            const SizedBox(height: 48),
            _buildSectionHeader(AppLocalizations.of(context)!.dangerZone),
            const SizedBox(height: 16),
            InkWell(
              onTap: _showDeleteAccountDialog,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red[700]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.deleteAccount,
                            style: GoogleFonts.workSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.permanentlyRemoveData,
                            style: GoogleFonts.workSans(
                              fontSize: 12,
                              color: Colors.red[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.red[300]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.workSans(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String value, bool showEdit = true}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.structuralBrown, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
                Text(value, style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: AppColors.structuralBrown)),
              ],
            ),
          ),
          if (showEdit) Icon(Icons.edit, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.structuralBrown.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.structuralBrown, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: AppColors.structuralBrown)),
                  Text(subtitle, style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccountConfirm, style: GoogleFonts.workSans(fontWeight: FontWeight.bold)),
        content: Text(AppLocalizations.of(context)!.deleteAccountConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual delete logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.supportContactSubmit)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
