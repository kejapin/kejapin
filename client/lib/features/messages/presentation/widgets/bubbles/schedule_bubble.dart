import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class ScheduleBubble extends StatelessWidget {
  final DateTime date;
  final String title;
  final bool isMe;
  final VoidCallback? onConfirm;
  final VoidCallback? onReschedule;

  const ScheduleBubble({
    super.key, 
    required this.date, 
    required this.title, 
    required this.isMe,
    this.onConfirm,
    this.onReschedule,
  });

  void _addToCalendar() {
    final event = Event(
      title: title,
      description: 'Scheduled meeting via Kejapin App',
      startDate: date,
      endDate: date.add(const Duration(hours: 1)),
      allDay: false,
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 8,
             offset: const Offset(0, 4)
           )
        ]
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
              // Add to Calendar Button
              IconButton(
                icon: const Icon(Icons.event_available, color: Colors.indigo, size: 20),
                onPressed: _addToCalendar,
                tooltip: 'Add to Calendar',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
                    onPressed: onReschedule,
                    style: OutlinedButton.styleFrom(
                       padding: EdgeInsets.zero,
                       side: const BorderSide(color: Colors.indigo),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.reschedule, 
                      style: const TextStyle(fontSize: 10, color: Colors.indigo, fontWeight: FontWeight.bold)
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
                       padding: EdgeInsets.zero,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.confirm, 
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
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
