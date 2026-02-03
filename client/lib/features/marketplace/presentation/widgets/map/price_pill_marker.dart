import 'package:flutter/material.dart';
import 'package:client/core/constants/app_colors.dart';

class PricePillMarker extends StatelessWidget {
  final String price;
  final bool isSelected;
  final bool isViewed;
  final VoidCallback onTap;

  const PricePillMarker({
    super.key,
    required this.price,
    this.isSelected = false,
    this.isViewed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color backgroundColor;
    Color textColor;
    double elevation;
    
    if (isSelected) {
      backgroundColor = AppColors.structuralBrown;
      textColor = Colors.white;
      elevation = 6.0;
    } else if (isViewed) {
      backgroundColor = Colors.grey[300]!; // Dimmed
      textColor = Colors.grey[700]!;
      elevation = 1.0;
    } else {
      backgroundColor = AppColors.champagne;
      textColor = AppColors.structuralBrown;
      elevation = 3.0;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.transparent, width: 0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: elevation,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          price,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isSelected ? 14 : 12,
            fontFamily: 'Work Sans', 
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
