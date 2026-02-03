import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleBubble extends StatelessWidget {
  final DateTime date;
  final String title;
  final bool isMe;

  const ScheduleBubble({super.key, required this.date, required this.title, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.indigo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${date.day}/${date.month} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
            style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (!isMe)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                       padding: EdgeInsets.zero,
                    ),
                    child: Text(AppLocalizations.of(context)!.reschedule, style: const TextStyle(fontSize: 10)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                       padding: EdgeInsets.zero,
                    ),
                    child: Text(AppLocalizations.of(context)!.confirm, style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
