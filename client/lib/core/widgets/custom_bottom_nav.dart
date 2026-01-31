import 'package:flutter/material.dart';
import 'animated_map_background.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_container.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(30),
        blur: 40,
        opacity: 0.75, // Frosted glass effect
        color: AppColors.structuralBrown,
        borderColor: AppColors.champagne.withOpacity(0.1),
        // borderColor duplicated removed
        child: Stack(
          children: [
            Positioned.fill(
              child: const AnimatedMapBackground(
                animate: true,
                opacity: 0.1,
                patternColor: AppColors.champagne,
                child: SizedBox(),
              ),
            ),
            SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.explore, 'Discovery'),
                  _buildNavItem(1, Icons.location_on, 'Life Pins'),
                  _buildNavItem(2, Icons.chat_bubble_outline, 'Messages'),
                  _buildNavItem(3, Icons.account_circle, 'Profile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Indicator
            if (isSelected)
              Positioned(
                top: 0,
                child: Container(
                  width: 32,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.champagne,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.champagne.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.champagne : AppColors.champagne.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: isSelected ? AppColors.champagne : AppColors.champagne.withOpacity(0.5),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
