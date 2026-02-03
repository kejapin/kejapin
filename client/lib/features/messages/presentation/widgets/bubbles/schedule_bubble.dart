import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class ScheduleBubble extends StatelessWidget {
  final DateTime date;
  final String title;
  final String? description;
  final Map<String, dynamic>? location;
  final bool isMe;
  final VoidCallback? onConfirm;
  final VoidCallback? onReschedule;

  const ScheduleBubble({
    super.key, 
    required this.date, 
    required this.title, 
    this.description,
    this.location,
    required this.isMe,
    this.onConfirm,
    this.onReschedule,
  });

  void _addToCalendar() {
    final event = Event(
      title: title,
      description: description ?? 'Scheduled meeting via Kejapin App',
      location: location?['name'] ?? 'Online / To be decided',
      startDate: date,
      endDate: date.add(const Duration(hours: 1)),
      allDay: false,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  Future<void> _openInMaps() async {
    if (location != null && location!['latitude'] != null && location!['longitude'] != null) {
      final lat = location!['latitude'];
      final lng = location!['longitude'];
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final uri = Uri.parse(googleMapsUrl);
      
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        debugPrint('Could not launch maps: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, 4)
           )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.event_available, color: Colors.indigo, size: 22),
                onPressed: _addToCalendar,
                tooltip: 'Add to Calendar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
            style: GoogleFonts.workSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
          ),
          
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: GoogleFonts.workSans(fontSize: 13, color: Colors.grey[700], height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (location != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _openInMaps,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.indigo, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location!['name'] ?? 'View on Map',
                        style: GoogleFonts.workSans(
                          fontSize: 12, 
                          color: Colors.indigo, 
                          fontWeight: FontWeight.w600
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.open_in_new, color: Colors.indigo, size: 12),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          if (!isMe)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReschedule,
                    style: OutlinedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 8),
                       side: const BorderSide(color: Colors.indigo),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.reschedule, 
                      style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 8),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm, 
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
