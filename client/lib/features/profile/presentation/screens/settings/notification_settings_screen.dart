import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/profile/data/profile_repository.dart';
import 'package:client/core/constants/app_colors.dart';
import 'package:client/core/widgets/custom_app_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _profileRepo = ProfileRepository();
  bool _isLoading = true;
  
  // State
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  
  bool _listingAlerts = true;
  bool _messageAlerts = true;
  bool _promoAlerts = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _profileRepo.getUserSettings();
      if (mounted) {
        setState(() {
          _pushEnabled = settings['push_enabled'] ?? true;
          _emailEnabled = settings['email_enabled'] ?? true;
          _smsEnabled = settings['sms_enabled'] ?? false;
          _listingAlerts = settings['alerts_listings'] ?? true;
          _messageAlerts = settings['alerts_messages'] ?? true;
          _promoAlerts = settings['alerts_promos'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    // Optimistic UI update
    setState(() {
      if (key == 'push_enabled') _pushEnabled = value;
      else if (key == 'email_enabled') _emailEnabled = value;
      else if (key == 'sms_enabled') _smsEnabled = value;
      else if (key == 'alerts_listings') _listingAlerts = value;
      else if (key == 'alerts_messages') _messageAlerts = value;
      else if (key == 'alerts_promos') _promoAlerts = value;
    });

    try {
      await _profileRepo.updateUserSettings({key: value});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save setting: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: 'NOTIFICATIONS', showSearch: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Channels'),
          const SizedBox(height: 16),
          _buildSwitchTile('Push Notifications', 'Receive alerts on your device', _pushEnabled, (v) => _updateSetting('push_enabled', v)),
          _buildSwitchTile('Email Notifications', 'Receive updates via email', _emailEnabled, (v) => _updateSetting('email_enabled', v)),
          _buildSwitchTile('SMS Notifications', 'Receive urgent alerts via SMS', _smsEnabled, (v) => _updateSetting('sms_enabled', v)),
          
          const SizedBox(height: 32),
          _buildSectionHeader('Preferences'),
          const SizedBox(height: 16),
          _buildSwitchTile('New Listings', 'Alerts for saved searches', _listingAlerts, (v) => _updateSetting('alerts_listings', v)),
          _buildSwitchTile('Messages', 'Chat messages from landlords/tenants', _messageAlerts, (v) => _updateSetting('alerts_messages', v)),
          _buildSwitchTile('Promotions & Tips', 'News and tips from Kejapin', _promoAlerts, (v) => _updateSetting('alerts_promos', v)),
        ],
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

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: SwitchListTile(
        activeColor: AppColors.mutedGold,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title, style: GoogleFonts.workSans(fontWeight: FontWeight.w600, color: AppColors.structuralBrown)),
        subtitle: Text(subtitle, style: GoogleFonts.workSans(fontSize: 12, color: Colors.grey)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
