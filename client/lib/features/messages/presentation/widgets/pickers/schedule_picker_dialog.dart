import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../../../l10n/app_localizations.dart';
import 'location_picker_dialog.dart';

class SchedulePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialType; // e.g., 'viewing'

  const SchedulePickerDialog({super.key, this.initialDate, this.initialType});

  @override
  State<SchedulePickerDialog> createState() => _SchedulePickerDialogState();
}

class _SchedulePickerDialogState extends State<SchedulePickerDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _selectedType;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic>? _selectedLocation;

  final List<Map<String, dynamic>> _appointmentTypes = [
    {'id': 'viewing', 'label': 'Property Viewing', 'icon': Icons.visibility},
    {'id': 'inspection', 'label': 'Inspection', 'icon': Icons.search},
    {'id': 'handover', 'label': 'Key Handover', 'icon': Icons.vpn_key},
    {'id': 'meeting', 'label': 'Meeting', 'icon': Icons.people},
    {'id': 'other', 'label': 'Other', 'icon': Icons.event},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedTime = widget.initialDate != null 
        ? TimeOfDay.fromDateTime(widget.initialDate!) 
        : TimeOfDay.now();
    
    _selectedType = 'viewing';
    if (widget.initialType != null) {
       final match = _appointmentTypes.firstWhere(
         (t) => t['label'] == widget.initialType || t['id'] == widget.initialType, 
         orElse: () => _appointmentTypes.first
       );
       _selectedType = match['id'];
       _titleController.text = match['label'];
    } else {
       _titleController.text = _appointmentTypes.first['label'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.mutedGold,
              onPrimary: Colors.white,
              surface: AppColors.structuralBrown,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _selectLocation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const LocationPickerDialog(),
    );
    if (result != null) {
      setState(() => _selectedLocation = result);
    }
  }

  void _submit() {
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    Navigator.pop(context, {
      'date': combinedDateTime.toIso8601String(),
      'title': _titleController.text.trim().isEmpty ? 'Meeting' : _titleController.text.trim(),
      'type': _selectedType,
      'description': _descriptionController.text.trim(),
      'location': _selectedLocation,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: GlassContainer(
        opacity: 0.95,
        blur: 20,
        color: AppColors.structuralBrown,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.schedule,
                style: GoogleFonts.workSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Title Input
              _buildLabel('Title'),
              const SizedBox(height: 8),
              _buildTextField(_titleController, 'e.g., Property Viewing'),
              const SizedBox(height: 16),

              // Description Input
              _buildLabel('Description (Optional)'),
              const SizedBox(height: 8),
              _buildTextField(_descriptionController, 'Add details...', maxLines: 2),
              const SizedBox(height: 16),

              // Appointment Type Selector
              _buildLabel('Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _appointmentTypes.map((type) {
                  final isSelected = _selectedType == type['id'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                         _selectedType = type['id'];
                         if (_titleController.text.isEmpty || _appointmentTypes.any((t) => t['label'] == _titleController.text)) {
                            _titleController.text = type['label'];
                         }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.mutedGold.withOpacity(0.3)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? AppColors.mutedGold 
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'],
                            size: 16,
                            color: isSelected ? AppColors.mutedGold : Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type['label'],
                            style: GoogleFonts.workSans(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // Location Picker
              _buildLabel('Meeting Point (Optional)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedLocation != null ? Icons.location_pin : Icons.add_location_alt,
                        color: _selectedLocation != null ? AppColors.mutedGold : Colors.white70
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedLocation != null 
                              ? _selectedLocation!['name'] 
                              : 'Select on Map',
                          style: GoogleFonts.workSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedLocation != null)
                        InkWell(
                            onTap: () => setState(() => _selectedLocation = null),
                            child: const Icon(Icons.close, color: Colors.white54, size: 18)
                        )
                       else 
                        const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Calendar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                padding: const EdgeInsets.all(8),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() => _selectedDate = selectedDay);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.mutedGold.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.mutedGold,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: GoogleFonts.workSans(color: Colors.red.shade200),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: GoogleFonts.workSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.mutedGold),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.mutedGold),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.workSans(color: Colors.white70),
                    weekendStyle: GoogleFonts.workSans(color: Colors.red.shade200),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Picker
              _buildLabel('Time'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.mutedGold),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: GoogleFonts.workSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: Colors.white54, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: GoogleFonts.workSans(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mutedGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Schedule',
                      style: GoogleFonts.workSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.workSans(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.workSans(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.workSans(color: Colors.white30),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mutedGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
