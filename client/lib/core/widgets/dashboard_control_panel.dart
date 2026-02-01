import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../constants/app_colors.dart';
import 'glass_container.dart';

class ControlPanelItem {
  final String title;
  final IconData icon;
  final String route;

  ControlPanelItem({required this.title, required this.icon, required this.route});
}

class DashboardControlPanel extends StatefulWidget {
  final List<ControlPanelItem> items;
  final String currentRoute;

  const DashboardControlPanel({
    super.key,
    required this.items,
    required this.currentRoute,
  });

  @override
  State<DashboardControlPanel> createState() => _DashboardControlPanelState();
}

class _DashboardControlPanelState extends State<DashboardControlPanel> {
  bool _isOpen = false;

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background overlay to close when clicking outside
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isOpen = false),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
        
        // Floating Toggle Button (right side)
        Positioned(
          right: 0,
          top: MediaQuery.of(context).size.height * 0.15,
          child: GestureDetector(
            onTap: _toggle,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.structuralBrown.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Icon(
                  _isOpen ? Icons.chevron_right : Icons.chevron_left,
                  color: AppColors.champagne,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // The Panel itself
        if (_isOpen)
          Positioned(
            right: 0,
            top: MediaQuery.of(context).size.height * 0.15 + 44, // Just below the toggle
            child: FadeInRight(
              duration: const Duration(milliseconds: 300),
              child: GlassContainer(
                width: 260,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                color: AppColors.structuralBrown,
                opacity: 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.settings_suggest_outlined, color: AppColors.mutedGold, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'CONTROL PANEL',
                            style: TextStyle(
                              color: AppColors.champagne,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10),
                    ...widget.items.map((item) => _buildMenuItem(context, item)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, ControlPanelItem item) {
    final bool isSelected = widget.currentRoute == item.route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _isOpen = false);
            context.go(item.route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mutedGold.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected ? AppColors.mutedGold : AppColors.champagne.withOpacity(0.8),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? AppColors.mutedGold : AppColors.champagne,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.circle, color: AppColors.mutedGold, size: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
