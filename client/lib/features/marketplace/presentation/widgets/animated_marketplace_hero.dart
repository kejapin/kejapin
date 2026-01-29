import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class AnimatedMarketplaceHero extends StatefulWidget {
  const AnimatedMarketplaceHero({super.key});

  @override
  State<AnimatedMarketplaceHero> createState() => _AnimatedMarketplaceHeroState();
}

class _AnimatedMarketplaceHeroState extends State<AnimatedMarketplaceHero>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _scrollController;
  
  late Animation<double> _float1;
  late Animation<double> _float2;
  late Animation<double> _float3;
  late Animation<double> _pulseAnimation;
  Animation<double>? _scrollAnimation;

  @override
  void initState() {
    super.initState();
    
    // Float animation for pins
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _float1 = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _float2 = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    _float3 = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );
    
    // Pulse animation for sun
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Slide in animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();
    
    // Horizontal scroll animation
    _scrollController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _scrollAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scrollController, curve: Curves.linear),
    );
    
    // Start window blink timer
    _startWindowBlink();
  }
  
  void _startWindowBlink() {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {});
        _startWindowBlink();
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;
        final height = isWeb ? 400.0 : 320.0;
        
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40 : 16,
            vertical: isWeb ? 24 : 16,
          ),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(isWeb ? 32 : 24),
            blur: 30,
            opacity: 0.15,
            color: Colors.white,
            borderColor: AppColors.mutedGold.withOpacity(0.3),
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isWeb ? 32 : 24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.alabaster.withOpacity(0.3),
                    AppColors.alabaster.withOpacity(0.1),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isWeb ? 32 : 24),
                child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated Sun
              Positioned(
                left: isWeb ? 100 : 40,
                top: isWeb ? 60 : 40,
                child: RepaintBoundary(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: isWeb ? 100 : 70,
                      height: isWeb ? 100 : 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mutedGold,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mutedGold.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Cityscape with infinite scroll
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOut,
                  )),
                  child: FadeTransition(
                    opacity: _slideController,
                    child: SizedBox(
                      height: height * 0.6,
                      child: AnimatedBuilder(
                        animation: _scrollAnimation ?? AlwaysStoppedAnimation(0.0),
                        builder: (context, child) {
                          final scrollValue = _scrollAnimation?.value ?? 0.0;
                          return Stack(
                            children: [
                              // First cityscape
                              Transform.translate(
                                offset: Offset(-constraints.maxWidth * scrollValue, 0),
                                child: CustomPaint(
                                  painter: CityscapePainter(
                                    timestamp: DateTime.now().millisecondsSinceEpoch,
                                  ),
                                  size: Size(constraints.maxWidth, height * 0.6),
                                ),
                              ),
                              // Second cityscape (for seamless loop)
                              Transform.translate(
                                offset: Offset(
                                  constraints.maxWidth * (1 - scrollValue),
                                  0,
                                ),
                                child: CustomPaint(
                                  painter: CityscapePainter(
                                    timestamp: DateTime.now().millisecondsSinceEpoch,
                                  ),
                                  size: Size(constraints.maxWidth, height * 0.6),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
              
              // Floating Location Pins with dynamic positioning
              AnimatedBuilder(
                animation: _scrollAnimation ?? AlwaysStoppedAnimation(0.0),
                builder: (context, child) {
                  final scrollValue = _scrollAnimation?.value ?? 0.0;
                  final scrollOffset = -constraints.maxWidth * scrollValue;
                  
                  return Stack(
                    children: [
                      _buildDynamicFloatingPin(
                        animation: _float1,
                        baseX: isWeb ? constraints.maxWidth * 0.25 : 60,
                        scrollOffset: scrollOffset,
                        containerWidth: constraints.maxWidth,
                        containerHeight: height,
                        size: isWeb ? 50 : 40,
                        pinIndex: 0,
                      ),
                      _buildDynamicFloatingPin(
                        animation: _float2,
                        baseX: isWeb ? constraints.maxWidth * 0.5 : constraints.maxWidth * 0.5,
                        scrollOffset: scrollOffset,
                        containerWidth: constraints.maxWidth,
                        containerHeight: height,
                        size: isWeb ? 60 : 45,
                        pinIndex: 1,
                      ),
                      _buildDynamicFloatingPin(
                        animation: _float3,
                        baseX: isWeb ? constraints.maxWidth * 0.7 : constraints.maxWidth - 80,
                        scrollOffset: scrollOffset,
                        containerWidth: constraints.maxWidth,
                        containerHeight: height,
                        size: isWeb ? 55 : 42,
                        pinIndex: 2,
                      ),
                    ],
                  );
                },
              ),
              
              // Content Overlay
              Positioned(
                left: 0,
                right: 0,
                top: isWeb ? 40 : 30,
                child: FadeTransition(
                  opacity: _slideController,
                  child: Column(
                    children: [
                      Text(
                        'Discover Your Next Home',
                        style: TextStyle(
                          fontSize: isWeb ? 42 : 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.structuralBrown,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Find verified listings with real commute times',
                        style: TextStyle(
                          fontSize: isWeb ? 18 : 14,
                          color: AppColors.structuralBrown.withOpacity(0.7),
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
        );
      },
    );
  }

  Widget _buildFloatingPin({
    required Animation<double> animation,
    required double left,
    required double bottom,
    required double size,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Positioned(
          left: left,
          bottom: bottom + animation.value,
          child: child!,
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.structuralBrown.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: AppColors.structuralBrown.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.location_on,
          color: AppColors.mutedGold,
          size: size * 0.7,
        ),
      ),
    );
  }
  
  // Get building height at a specific x position
  double _getBuildingHeightAtPosition(double x, double containerWidth, double containerHeight) {
    // Building definitions (same as in CityscapePainter)
    final buildings = [
      {'x': 0.0, 'width': 0.08, 'height': 0.5},
      {'x': 0.09, 'width': 0.06, 'height': 0.35},
      {'x': 0.16, 'width': 0.07, 'height': 0.6},
      {'x': 0.24, 'width': 0.09, 'height': 0.45},
      {'x': 0.34, 'width': 0.08, 'height': 0.75},
      {'x': 0.43, 'width': 0.07, 'height': 0.55},
      {'x': 0.51, 'width': 0.10, 'height': 0.8},
      {'x': 0.62, 'width': 0.08, 'height': 0.65},
      {'x': 0.71, 'width': 0.09, 'height': 0.5},
      {'x': 0.81, 'width': 0.07, 'height': 0.7},
      {'x': 0.89, 'width': 0.06, 'height': 0.4},
      {'x': 0.96, 'width': 0.04, 'height': 0.55},
    ];
    
    final normalizedX = (x % containerWidth) / containerWidth;
    
    for (final building in buildings) {
      final buildingX = building['x']!;
      final buildingWidth = building['width']!;
      
      if (normalizedX >= buildingX && normalizedX <= buildingX + buildingWidth) {
        return containerHeight * 0.6 * building['height']!;
      }
    }
    
    return 0; // No building at this position
  }
  
  Widget _buildDynamicFloatingPin({
    required Animation<double> animation,
    required double baseX,
    required double scrollOffset,
    required double containerWidth,
    required double containerHeight,
    required double size,
    required int pinIndex,
  }) {
    // Calculate position considering scroll
    final adjustedX = baseX - scrollOffset;
    final wrappedX = adjustedX % containerWidth;
    
    // Get building height at this position
    final buildingHeight = _getBuildingHeightAtPosition(wrappedX, containerWidth, containerHeight);
    
    // Pin floats 30-50px above the building (with gentle bob from animation)
    final hoverHeight = 40 + animation.value;
    final targetBottom = buildingHeight + hoverHeight;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      left: wrappedX - (size / 2), // Center the pin
      bottom: targetBottom,
      child: RepaintBoundary(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.structuralBrown.withOpacity(0.95),
                AppColors.structuralBrown.withOpacity(0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.structuralBrown.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 3,
              ),
              BoxShadow(
                color: AppColors.mutedGold.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.location_on,
            color: AppColors.mutedGold,
            size: size * 0.7,
          ),
        ),
      ),
    );
  }
}

class CityscapePainter extends CustomPainter {
  final int timestamp;
  
  CityscapePainter({this.timestamp = 0});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.structuralBrown
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Define building heights as percentages of the available height
    final buildings = [
      {'x': 0.0, 'width': 0.08, 'height': 0.5},
      {'x': 0.09, 'width': 0.06, 'height': 0.35},
      {'x': 0.16, 'width': 0.07, 'height': 0.6},
      {'x': 0.24, 'width': 0.09, 'height': 0.45},
      {'x': 0.34, 'width': 0.08, 'height': 0.75},
      {'x': 0.43, 'width': 0.07, 'height': 0.55},
      {'x': 0.51, 'width': 0.10, 'height': 0.8},
      {'x': 0.62, 'width': 0.08, 'height': 0.65},
      {'x': 0.71, 'width': 0.09, 'height': 0.5},
      {'x': 0.81, 'width': 0.07, 'height': 0.7},
      {'x': 0.89, 'width': 0.06, 'height': 0.4},
      {'x': 0.96, 'width': 0.04, 'height': 0.55},
    ];
    
    final random = math.Random(timestamp ~/ 2000); // Change seed every 2000ms
    
    // Calculate total windows and select 2-3 to be "off"
    int totalWindows = 0;
    for (final building in buildings) {
      final height = size.height * building['height']!;
      final windowHeight = height * 0.08;
      final rows = (height / (windowHeight * 2.5)).floor();
      totalWindows += rows * 2; // 2 windows per row
    }
    
    // Pick 2-3 random windows to be dark
    final darkWindowCount = 2 + random.nextInt(2); // 2 or 3
    final darkWindows = <int>{};
    for (var i = 0; i < darkWindowCount; i++) {
      darkWindows.add(random.nextInt(totalWindows));
    }
    
    int windowIndex = 0;
    
    for (var bIndex = 0; bIndex < buildings.length; bIndex++) {
      final building = buildings[bIndex];
      final x = size.width * building['x']!;
      final width = size.width * building['width']!;
      final height = size.height * building['height']!;
      
      // Building
      final rect = Rect.fromLTWH(
        x,
        size.height - height,
        width,
        height,
      );
      canvas.drawRect(rect, paint);
      
      // Windows
      final windowPaint = Paint()
        ..color = AppColors.alabaster
        ..style = PaintingStyle.fill;
      
      final windowWidth = width * 0.25;
      final windowHeight = height * 0.08;
      final windowsPerRow = 2;
      final rows = (height / (windowHeight * 2.5)).floor();
      
      for (var row = 0; row < rows; row++) {
        for (var col = 0; col < windowsPerRow; col++) {
          // Check if this window should be dark
          final isLit = !darkWindows.contains(windowIndex);
          windowIndex++;
          
          if (isLit) {
            final wx = x + (width * 0.2) + (col * width * 0.4);
            final wy = size.height - height + (row * windowHeight * 2.5) + windowHeight;
            
            canvas.drawRect(
              Rect.fromLTWH(wx, wy, windowWidth, windowHeight),
              windowPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(CityscapePainter oldDelegate) => 
    oldDelegate.timestamp != timestamp;
}
