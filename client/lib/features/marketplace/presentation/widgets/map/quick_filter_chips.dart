import 'package:flutter/material.dart';
import 'package:client/core/constants/app_colors.dart';

class QuickFilterChips extends StatelessWidget {
  final bool isClosestActive;
  final bool isCheapestActive;
  final VoidCallback onClosestTap;
  final VoidCallback onCheapestTap;
  final Function(String) onFilterTap;

  const QuickFilterChips({
    super.key,
    required this.isClosestActive,
    required this.isCheapestActive,
    required this.onClosestTap,
    required this.onCheapestTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Smart Filters
          _buildSmartChip(
            label: '📍 Closest to Me',
            isActive: isClosestActive,
            onTap: onClosestTap,
          ),
          const SizedBox(width: 8),
          _buildSmartChip(
            label: '💰 Cheapest',
            isActive: isCheapestActive,
            onTap: onCheapestTap,
          ),
          const SizedBox(width: 8),
          
          // Divider
          Container(
            height: 24,
            width: 1,
            color: Colors.grey.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          const SizedBox(width: 8),

          // Standard Filters
          _buildChip(label: 'Price Range ▾', onTap: () => onFilterTap('price')),
          const SizedBox(width: 8),
          _buildChip(label: 'Beds ▾', onTap: () => onFilterTap('beds')),
          const SizedBox(width: 8),
          _buildChip(label: 'Type ▾', onTap: () => onFilterTap('type')),
          const SizedBox(width: 8),
          _buildChip(label: 'More Filters', onTap: () => onFilterTap('more'), isOutlined: true),
        ],
      ),
    );
  }

  Widget _buildSmartChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.structuralBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.structuralBrown : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.champagne : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onTap,
    bool isOutlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOutlined ? AppColors.structuralBrown : Colors.grey.shade300,
            width: isOutlined ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isOutlined ? AppColors.structuralBrown : Colors.black87,
            fontWeight: isOutlined ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
