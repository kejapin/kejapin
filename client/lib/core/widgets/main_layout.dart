import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_bottom_nav.dart';
import 'package:flutter/foundation.dart';
import '../globals.dart';
import 'app_drawer.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/widgets/complete_profile_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  Future<void> _checkProfileCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool('profile_popup_shown') ?? false;
    
    if (hasShown) return;

    try {
      final profile = await ProfileRepository().getProfile();
      if (!profile.profileCompleted) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder: (context) => CompleteProfileDialog(profile: profile),
          );
          await prefs.setBool('profile_popup_shown', true);
        }
      }
    } catch (e) {
      print('Error checking profile completion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: rootScaffoldKey,
      drawer: const AppDrawer(),
      drawerScrimColor: Colors.transparent,
      body: widget.child,
      bottomNavigationBar: kIsWeb 
          ? null 
          : CustomBottomNav(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (index) => _onItemTapped(index, context),
            ),
      extendBody: true,
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/marketplace')) return 0;
    if (location.startsWith('/life-pins')) return 1;
    if (location.startsWith('/messages')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/marketplace');
        break;
      case 1:
        context.go('/life-pins');
        break;
      case 2:
        context.go('/messages');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
