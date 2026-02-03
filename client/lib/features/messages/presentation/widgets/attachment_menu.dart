import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AttachmentMenu extends StatelessWidget {
  final Function(String) onAttachmentSelected;

  const AttachmentMenu({super.key, required this.onAttachmentSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.structuralBrown,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.shareContent,
            style: GoogleFonts.workSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildAttachmentOption(Icons.image, AppLocalizations.of(context)!.gallery, "gallery", Colors.purple),
              _buildAttachmentOption(Icons.camera_alt, AppLocalizations.of(context)!.camera, "camera", Colors.red),
              _buildAttachmentOption(Icons.location_on, AppLocalizations.of(context)!.location, "location", Colors.green),
              _buildAttachmentOption(Icons.description, AppLocalizations.of(context)!.lease, "lease", Colors.blue),
              _buildAttachmentOption(Icons.real_estate_agent, AppLocalizations.of(context)!.property, "property", Colors.orange),
              _buildAttachmentOption(Icons.build, AppLocalizations.of(context)!.repair, "repair", Colors.brown),
              _buildAttachmentOption(Icons.payment, AppLocalizations.of(context)!.payment, "payment", Colors.teal),
              _buildAttachmentOption(Icons.calendar_today, AppLocalizations.of(context)!.schedule, "schedule", Colors.indigo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, String id, Color color) {
    return InkWell(
      onTap: () => onAttachmentSelected(id),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.workSans(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
