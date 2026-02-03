import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';
import 'package:client/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateToNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final isLoggedIn = await AuthRepository().isLoggedIn();
      if (isLoggedIn) {
        context.go('/marketplace');
      } else {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Animated ripple effect
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final delay = index * 0.33;
                  final animation = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(delay, 1.0, curve: Curves.easeOut),
                  );
                  return Center(
                    child: Opacity(
                      opacity: (1 - animation.value).clamp(0.0, 0.4),
                      child: Container(
                        width: 200 + (animation.value * 400),
                        height: 200 + (animation.value * 400),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mutedGold,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
            // Center content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with pulse animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.95, end: 1.05),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 120,
                              height: 120,
                            ),
                          );
                        },
                        onEnd: () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.mutedGold,
                            Color(0xFFF9D976),
                            AppColors.mutedGold,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          AppLocalizations.of(context)!.appTitle.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.landingTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.alabaster.withOpacity(0.8),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //Loading indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.mutedGold.withOpacity(0.4),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
