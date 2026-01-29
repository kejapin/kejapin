import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_colors.dart';

class WebLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool showFooter;

  const WebLayoutWrapper({
    super.key,
    required this.child,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }

    if (!showFooter) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        const WebFooter(),
      ],
    );
  }
}

class WebFooter extends StatefulWidget {
  const WebFooter({super.key});

  @override
  State<WebFooter> createState() => _WebFooterState();
}

class _WebFooterState extends State<WebFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.structuralBrown,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main footer content
            Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo and tagline
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'kejapin',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Don't just list it. Pin it.",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedGold.withOpacity(0.8),
                                letterSpacing: 3,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        // Links section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFooterColumn(
                              'Product',
                              ['Features', 'Pricing', 'How it Works', 'FAQs'],
                            ),
                            const SizedBox(width: 40),
                            _buildFooterColumn(
                              'Company',
                              ['About Us', 'Careers', 'Blog', 'Press'],
                            ),
                            const SizedBox(width: 40),
                            _buildFooterColumn(
                              'Support',
                              ['Help Center', 'Contact', 'Terms', 'Privacy'],
                            ),
                            const SizedBox(width: 40),
                            _buildFooterColumn(
                              'Connect',
                              ['Twitter', 'Facebook', 'Instagram', 'LinkedIn'],
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and tagline
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/logo.png',
                                  height: 48,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'kejapin',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Don't just list it. Pin it.",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.mutedGold.withOpacity(0.8),
                                letterSpacing: 3,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                        // Links section
                        Wrap(
                          spacing: 60,
                          runSpacing: 40,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildFooterColumn(
                              'Product',
                              ['Features', 'Pricing', 'How it Works', 'FAQs'],
                            ),
                            _buildFooterColumn(
                              'Company',
                              ['About Us', 'Careers', 'Blog', 'Press'],
                            ),
                            _buildFooterColumn(
                              'Support',
                              ['Help Center', 'Contact', 'Terms', 'Privacy'],
                            ),
                            _buildFooterColumn(
                              'Connect',
                              ['Twitter', 'Facebook', 'Instagram', 'LinkedIn'],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            // Bottom bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text(
                        '© 2026 kejapin.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'All rights reserved.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '•',
                        style: TextStyle(
                          color: AppColors.mutedGold.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Built with structural intelligence.',
                        style: TextStyle(
                          color: AppColors.mutedGold.withOpacity(0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> links) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.mutedGold,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
