import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class PropertyBubble extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final bool isMe;

  const PropertyBubble({super.key, required this.propertyData, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (propertyData['image'] != null)
            Image.network(
              propertyData['image'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyData['title'] ?? 'Unknown Property',
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  propertyData['price'] ?? '',
                  style: GoogleFonts.workSans(color: AppColors.structuralBrown, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to property details
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.structuralBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(AppLocalizations.of(context)!.viewDetails),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
