import 'package:flutter/material.dart';

class MarketplaceBackground extends StatelessWidget {
  final Widget child;

  const MarketplaceBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFBF7), // Soft Cream background
      child: Stack(
        children: [
          // Custom SVG Pattern Painter
          Positioned.fill(
            child: Opacity(
              opacity: 0.1, // Adjusted for subtlety
              child: CustomPaint(
                painter: MapPatternPainter(),
              ),
            ),
          ),
          
          // Child Content (Scrollable content sits on top)
          child,
        ],
      ),
    );
  }
}

class MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final thickPaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Thicker for main roads

    final path = Path();
    final roadPath = Path();

    // Replicating the "Architectural Map" style from the SVG
    
    // Main Roads (Thick Lines) - Abstract representation
    roadPath.moveTo(-50, size.height * 0.2);
    roadPath.lineTo(size.width + 50, size.height * 0.25);
    
    roadPath.moveTo(size.width * 0.5, -50);
    roadPath.lineTo(size.width * 0.48, size.height + 50);
    
    roadPath.moveTo(-50, size.height * 0.7);
    roadPath.lineTo(size.width + 50, size.height * 0.65);

    // Grid Lines / smaller streets
    // Verticals
    for (double i = 0.15; i < 0.4; i += 0.12) {
      path.moveTo(size.width * i, 0);
      path.lineTo(size.width * i, size.height * 0.3);
    }
    
    // Horizontals
    for (double i = 0.1; i < 0.3; i += 0.08) {
       path.moveTo(0, size.height * i);
       path.lineTo(size.width * 0.5, size.height * i);
    }

    // Curves / Organic Paths
    path.moveTo(size.width * 0.5, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.35, size.width, size.height * 0.3);
    
    path.moveTo(size.width * 0.5, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.6, size.height * 0.65);
    path.lineTo(size.width, size.height * 0.65);

    // Bottom Grid Section
    for (double i = 0.1; i < 0.5; i += 0.12) {
       path.moveTo(size.width * i, size.height * 0.7);
       path.lineTo(size.width * i, size.height);
    }
    
    for (double i = 0.8; i < 1.0; i += 0.08) {
       path.moveTo(0, size.height * i);
       path.lineTo(size.width * 0.5, size.height * i);
    }

    // Draw Paths
    canvas.drawPath(path, paint);
    canvas.drawPath(roadPath, thickPaint);

    // Draw Shapes (Rectangles/Buildings) - mimicking the SVG blocks
    final fillPaint = Paint()
      ..color = const Color(0xFF4A3728)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.05, 60, 90), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.75, size.height * 0.07, 70, 60), fillPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.65, size.height * 0.18, 100, 30), fillPaint);

    // Circles / Landmarks
    canvas.drawCircle(Offset(size.width * 0.49, size.height * 0.245), 10, fillPaint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.68), 8, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
