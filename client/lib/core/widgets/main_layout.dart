import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'custom_bottom_nav.dart';
import 'package:flutter/foundation.dart';
import '../globals.dart';
import 'app_drawer.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: rootScaffoldKey,
      drawer: const AppDrawer(),
      drawerScrimColor: Colors.transparent,
      body: child,
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
