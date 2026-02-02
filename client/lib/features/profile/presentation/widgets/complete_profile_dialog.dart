import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../data/profile_repository.dart';

class CompleteProfileDialog extends StatelessWidget {
  final UserProfile profile;
  const CompleteProfileDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.mutedGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 40,
                  color: AppColors.mutedGold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Complete Your Profile",
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.structuralBrown,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You're almost there! Add a username and your name to make it easier for others to connect with you.",
                textAlign: TextAlign.center,
                style: GoogleFonts.workSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/profile/edit', extra: profile);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.structuralBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "DO IT NOW",
                    style: GoogleFonts.workSans(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "LATER",
                  style: GoogleFonts.workSans(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
