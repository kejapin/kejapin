import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';

class DocumentBubble extends StatelessWidget {
  final String documentUrl;
  final String documentName;
  final bool isMe;

  const DocumentBubble({
    super.key,
    required this.documentUrl,
    required this.documentName,
    required this.isMe,
  });

  IconData _getFileIcon() {
    if (documentName.toLowerCase().endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (documentName.toLowerCase().endsWith('.doc') || 
               documentName.toLowerCase().endsWith('.docx')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  Color _getFileColor() {
    if (documentName.toLowerCase().endsWith('.pdf')) {
      return Colors.red;
    } else if (documentName.toLowerCase().endsWith('.doc') || 
               documentName.toLowerCase().endsWith('.docx')) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  Future<void> _openDocument() async {
    final uri = Uri.parse(documentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDocument,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe 
              ? AppColors.mutedGold.withOpacity(0.9)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getFileColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFileIcon(),
                color: _getFileColor(),
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentName,
                    style: GoogleFonts.workSans(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.download,
                        size: 14,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to open',
                        style: GoogleFonts.workSans(
                          color: isMe ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isMe ? Colors.white70 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
