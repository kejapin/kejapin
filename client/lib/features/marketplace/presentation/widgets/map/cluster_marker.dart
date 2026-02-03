import 'package:flutter/material.dart';
import 'package:client/core/constants/app_colors.dart';

class ClusterMarker extends StatelessWidget {
  final int count;
  final String? averagePrice;
  final VoidCallback onTap;

  const ClusterMarker({
    super.key,
    required this.count,
    this.averagePrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // Fixed width for pill shape
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.mutedGold,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count Properties',
              style: const TextStyle(
                color: AppColors.structuralBrown,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (averagePrice != null)
              Text(
                'Avg: $averagePrice',
                style: const TextStyle(
                  color: AppColors.structuralBrown,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
