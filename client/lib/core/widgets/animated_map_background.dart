import 'package:flutter/material.dart';

class AnimatedMapBackground extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Color patternColor;
  final double opacity;

  const AnimatedMapBackground({
    super.key,
    required this.child,
    this.animate = false,
    this.patternColor = const Color(0xFF4A3728), 
    this.opacity = 0.1,
  });

  @override
  State<AnimatedMapBackground> createState() => _AnimatedMapBackgroundState();
}

class _AnimatedMapBackgroundState extends State<AnimatedMapBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 20), // Traffic speed
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMapBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Static Structure Layer (Cached)
        Positioned.fill(
          child: Opacity(
            opacity: widget.opacity,
            child: RepaintBoundary( // CACHE THIS LAYER
              child: CustomPaint(
                painter: StaticMapPatternPainter(color: widget.patternColor),
              ),
            ),
          ),
        ),

        // 2. Animated Traffic Layer (Isolated Repaint)
        if (widget.animate)
          Positioned.fill(
            child: Opacity(
              opacity: widget.opacity,
              child: RepaintBoundary( // ISOLATE ANIMATION
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: TrafficMapPainter(
                        animationValue: _controller.value,
                        color: widget.patternColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        
        // 3. Child Content
        widget.child,
      ],
    );
  }
}

class StaticMapPatternPainter extends CustomPainter {
  final Color color;

  StaticMapPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final thickPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    
    // Grid Lines (Vertical)
    for (double i = 0.15; i < 1.0; i += 0.12) {
      path.moveTo(size.width * i, 0);
      path.lineTo(size.width * i, size.height);
    }
    // Grid Lines (Horizontal)
    for (double i = 0.1; i < 1.0; i += 0.08) {
       path.moveTo(0, size.height * i);
       path.lineTo(size.width, size.height * i);
    }
    canvas.drawPath(path, paint);

    // Organic Roads (Thicker)
    final organicPath = Path();
    organicPath.moveTo(0, size.height * 0.4);
    organicPath.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width, size.height * 0.45);
    
    organicPath.moveTo(size.width * 0.2, 0);
    organicPath.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.3, size.height);

    canvas.drawPath(organicPath, thickPaint);
  }

  @override
  bool shouldRepaint(covariant StaticMapPatternPainter oldDelegate) => oldDelegate.color != color;
}

class TrafficMapPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  TrafficMapPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final carPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Must recreate organic paths to trace them. 
    // Optimization: Since paths are simple bezier curves, reconstructing is cheap.
    // If paths were complex, we'd pass them in or cache them.
    final organicPath = Path();
    organicPath.moveTo(0, size.height * 0.4);
    organicPath.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width, size.height * 0.45);
    
    final organicPath2 = Path();
    organicPath2.moveTo(size.width * 0.2, 0);
    organicPath2.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.3, size.height);

    // Simulate cars
    // Path 1
    for (final metric in organicPath.computeMetrics()) {
       final length = metric.length;
       final offset1 = (length * animationValue) % length;
       final t1 = metric.getTangentForOffset(offset1);
       if (t1 != null) canvas.drawCircle(t1.position, 3.0, carPaint);

       final offset2 = ((length * animationValue) + (length * 0.33)) % length;
       final t2 = metric.getTangentForOffset(offset2);
       if (t2 != null) canvas.drawCircle(t2.position, 3.0, carPaint);
       
       final offset3 = ((length * animationValue) + (length * 0.66)) % length;
       final t3 = metric.getTangentForOffset(offset3);
       if (t3 != null) canvas.drawCircle(t3.position, 3.0, carPaint);
    }

    // Path 2
    for (final metric in organicPath2.computeMetrics()) {
       final length = metric.length;
       final offset1 = (length * (1 - animationValue)) % length; // Reverse direction
       final t1 = metric.getTangentForOffset(offset1);
       if (t1 != null) canvas.drawCircle(t1.position, 3.0, carPaint);
       
       final offset2 = ((length * (1 - animationValue)) + (length * 0.5)) % length;
       final t2 = metric.getTangentForOffset(offset2);
       if (t2 != null) canvas.drawCircle(t2.position, 3.0, carPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrafficMapPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue || oldDelegate.color != color;
}
