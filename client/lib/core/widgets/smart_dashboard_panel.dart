import 'package:flutter/material.dart';
import '../../features/profile/data/profile_repository.dart';
import 'dashboard_control_panel.dart';

class SmartDashboardPanel extends StatelessWidget {
  final String currentRoute;

  const SmartDashboardPanel({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: ProfileRepository().getProfile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final profile = snapshot.data!;
        final isAdmin = profile.email == 'kejapinmail@gmail.com';
        
        List<ControlPanelItem> items = [];

        if (isAdmin) {
          items = [
            ControlPanelItem(title: 'Admin Console', icon: Icons.security_outlined, route: '/admin-dashboard'),
            ControlPanelItem(title: 'Partner Verifications', icon: Icons.verified_user_outlined, route: '/admin/verifications'),
            ControlPanelItem(title: 'Market Monitoring', icon: Icons.visibility_outlined, route: '/marketplace'),
            ControlPanelItem(title: 'UI Component Lab', icon: Icons.science_outlined, route: '/gallery'),
            ControlPanelItem(title: 'My Profile', icon: Icons.admin_panel_settings_outlined, route: '/profile'),
          ];
        } else if (profile.role == 'LANDLORD' || profile.role == 'AGENT') {
          items = [
            ControlPanelItem(title: 'Partner Home', icon: Icons.dashboard_outlined, route: '/landlord-dashboard'),
            ControlPanelItem(title: 'Manage Listings', icon: Icons.inventory_2_outlined, route: '/manage-listings'),
            ControlPanelItem(title: 'Post Property', icon: Icons.add_home_work_outlined, route: '/create-listing'),
            ControlPanelItem(title: 'My Profile', icon: Icons.badge_outlined, route: '/profile'),
          ];
        } else {
          // Tenant
          items = [
            ControlPanelItem(title: 'Life-Hub Home', icon: Icons.window_outlined, route: '/tenant-dashboard'),
            ControlPanelItem(title: 'My Geo-Pins', icon: Icons.explore_outlined, route: '/life-pins'),
            ControlPanelItem(title: 'Saved Listings', icon: Icons.favorite_border, route: '/saved'),
            ControlPanelItem(title: 'My Profile', icon: Icons.person_outline, route: '/profile'),
          ];
        }

        return DashboardControlPanel(
          items: items,
          currentRoute: currentRoute,
        );
      },
    );
  }
}
