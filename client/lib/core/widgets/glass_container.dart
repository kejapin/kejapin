import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final Color color;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 30,
    this.opacity = 0.25,
    this.color = Colors.white,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          constraints: constraints,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.3),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity((opacity + 0.15).clamp(0.0, 1.0)),
                color.withOpacity(opacity.clamp(0.0, 1.0)),
                color.withOpacity((opacity - 0.05).clamp(0.0, 1.0)),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Increased shadow
                blurRadius: 30, // Increased from 20
                spreadRadius: 8, // Increased from 5
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
