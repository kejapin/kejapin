import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationBubble extends StatelessWidget {
  final String locationName;
  final bool isMe;

  const LocationBubble({super.key, required this.locationName, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageGreen.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.sageGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.location,
                  style: GoogleFonts.workSans(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  locationName,
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
