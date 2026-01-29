import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'Notification Center', showSearch: false),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: GoogleFonts.workSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.structuralBrown,
                ),
              ),
              Text(
                'MARK ALL READ',
                style: GoogleFonts.workSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedGold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('MESSAGES'),
          _buildNotificationTile(
            icon: Icons.chat_bubble,
            title: 'Architectural Inquiry',
            time: '2m ago',
            description: 'David sent a message regarding the structural blueprints for the Kileleshwa project.',
            isUnread: true,
          ),
          _buildNotificationTile(
            icon: Icons.maps_ugc,
            title: 'Property Tour Confirmed',
            time: '1h ago',
            description: 'Your visit to Azure Towers is scheduled for tomorrow at 10:00 AM.',
            isUnread: false,
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('FINANCIAL'),
          _buildNotificationTile(
            icon: Icons.receipt_long,
            title: 'Rent Invoice Generated',
            time: '3h ago',
            description: 'Invoice #KJ-882 for October is ready. Total due: 125,000 KES.',
            isUnread: true,
          ),
          _buildNotificationTile(
            icon: Icons.payments,
            title: 'Security Deposit Refunded',
            time: 'Yesterday',
            description: 'The deposit for Riverside Drive has been successfully processed.',
            isUnread: false,
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('SYSTEM'),
          _buildNotificationTile(
            icon: Icons.settings_suggest,
            title: 'Market Report Update',
            time: '2d ago',
            description: 'New Q4 data available for Westlands area property appreciation trends.',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.workSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String time,
    required String description,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isUnread ? null : Border.all(color: Colors.transparent),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Icon(icon, color: AppColors.structuralBrown, size: 22),
              ),
              if (isUnread)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.mutedGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.alabaster, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.structuralBrown,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.workSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.workSans(
                    fontSize: 14,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
