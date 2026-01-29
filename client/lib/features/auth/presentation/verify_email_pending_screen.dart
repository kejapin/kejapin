import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class VerifyEmailPendingScreen extends StatefulWidget {
  final String email;

  const VerifyEmailPendingScreen({super.key, required this.email});

  @override
  State<VerifyEmailPendingScreen> createState() => _VerifyEmailPendingScreenState();
}

class _VerifyEmailPendingScreenState extends State<VerifyEmailPendingScreen> {
  bool _isResending = false;
  final _authRepository = AuthRepository();

  void _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await _authRepository.resendVerificationEmail(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: kIsWeb
                ? Container(color: AppColors.structuralBrown)
                : AnimatedMeshGradient(
                    colors: [
                      AppColors.structuralBrown,
                      const Color(0xFF5D4037),
                      AppColors.mutedGold.withOpacity(0.4),
                      AppColors.structuralBrown,
                    ],
                    options: AnimatedMeshGradientOptions(speed: 2),
                  ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: GlassContainer(
                  padding: const EdgeInsets.all(40),
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Icon
                      ZoomIn(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.mutedGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_unread_outlined,
                            color: AppColors.mutedGold,
                            size: 64,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Text(
                        "Verify your email",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                          children: [
                            const TextSpan(text: "We've sent a verification link to\n"),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                color: AppColors.mutedGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text(
                        "Please check your inbox and click the link to activate your account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 48),
                      
                      // Resend Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isResending ? null : _resendEmail,
                          icon: _isResending 
                            ? const SizedBox.shrink()
                            : const Icon(Icons.send_rounded, size: 18),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mutedGold,
                            foregroundColor: AppColors.structuralBrown,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          label: _isResending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.structuralBrown,
                                  ),
                                )
                              : const Text(
                                  "Resend Link",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // I've Verified Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.mutedGold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "I've Verified My Email",
                            style: TextStyle(
                              color: AppColors.mutedGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Back to Login / Wrong Email
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          "Wrong email? Go back",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
