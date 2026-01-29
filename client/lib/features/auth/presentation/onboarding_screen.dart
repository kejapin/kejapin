import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Find Your Perfect Fit",
      description:
          "Discover homes curated by data and design. We analyze what matters to match you with properties that truly fit your lifestyle.",
      image: 'assets/images/onboarding/discovery.png',
    ),
    OnboardingPage(
      title: "Plan Your Route. Find Your Life Pins.",
      description:
          "Visualize your commute and calculate real travel times to work, gym, and all the places that matter in your life.",
      image: 'assets/images/onboarding/life_pins.png',
    ),
    OnboardingPage(
      title: "Complete Cost Transparency",
      description:
          "See the total monthly cost including rent, commute, and utilities. No hidden fees, just honest numbers.",
      image: 'assets/images/onboarding/transparency.png',
    ),
    OnboardingPage(
      title: "Trust Built In",
      description:
          "Verified landlords, secure payments, and a community-focused platform. Find your home with confidence.",
      image: 'assets/images/onboarding/trust.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Responsive constraint for web
    final maxWidth = MediaQuery.of(context).size.width > 600 ? 600.0 : double.infinity;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // Subtle effect
              child: kIsWeb
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.alabaster,
                            AppColors.mutedGold.withOpacity(0.2),
                            AppColors.structuralBrown.withOpacity(0.1),
                            AppColors.alabaster,
                          ],
                        ),
                      ),
                    )
                  : AnimatedMeshGradient(
                      colors: [
                        AppColors.alabaster,
                        AppColors.mutedGold.withOpacity(0.2),
                        AppColors.structuralBrown.withOpacity(0.1),
                        AppColors.alabaster,
                      ],
                      options: AnimatedMeshGradientOptions(speed: 1), // Slow speed for performance
                    ),
            ),
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SafeArea(
                child: Column(
                  children: [
                    // Skip button
                    Padding(
                      padding: const EdgeInsets.only(right: 20, top: 12),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () => context.go('/login'),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.alabaster.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.structuralBrown,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (value) => setState(() => _currentPage = value),
                        itemCount: _pages.length,
                        itemBuilder: (context, index) => _buildPage(_pages[index], index),
                      ),
                    ),
                    _buildBottomControls(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page ?? 0) - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.structuralBrown.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      page.image,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.structuralBrown.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.structuralBrown,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    page.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.structuralBrown.withOpacity(0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.structuralBrown
                      : AppColors.structuralBrown.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          // Next/Get Started button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.animateToPage(
                  _currentPage + 1,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.structuralBrown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                if (_currentPage < _pages.length - 1) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
  });
}
