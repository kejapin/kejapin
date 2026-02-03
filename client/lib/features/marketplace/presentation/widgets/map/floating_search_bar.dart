import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:client/core/constants/app_colors.dart';

class FloatingSearchBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;

  const FloatingSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 50,
      borderRadius: 25,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.1)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.structuralBrown),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search location...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                  contentPadding: EdgeInsets.only(bottom: 4), // Vertically center text
                ),
                style: const TextStyle(color: Colors.black87),
                onChanged: onSearchChanged,
              ),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune, color: AppColors.structuralBrown, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
