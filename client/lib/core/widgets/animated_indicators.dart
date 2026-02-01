import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// --- 1. REUSABLE ANIMATION WRAPPERS ---

class LoopAnimation extends StatefulWidget {
  final Widget Function(BuildContext, double, Widget?) builder;
  final Duration duration;
  final Widget? child;
  final bool reverse;

  const LoopAnimation({
    super.key,
    required this.builder,
    required this.duration,
    this.child,
    this.reverse = false,
  });

  @override
  State<LoopAnimation> createState() => _LoopAnimationState();
}

class _LoopAnimationState extends State<LoopAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.reverse) {
      _controller.repeat(reverse: true);
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, child) => widget.builder(ctx, _controller.value, child),
      child: widget.child,
    );
  }
}

class Ping extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const Ping({super.key, required this.child, this.duration = const Duration(seconds: 2)});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: duration,
      builder: (context, val, child) {
        return Opacity(
          opacity: (1.0 - val).clamp(0, 1),
          child: Transform.scale(scale: 1.0 + val * 0.5, child: child),
        );
      },
      child: child,
    );
  }
}

class Bounce extends StatelessWidget {
  final Widget child;
  final double amount;
  const Bounce({super.key, required this.child, this.amount = 10});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(milliseconds: 1500),
      reverse: true,
      builder: (context, val, child) {
        final offset = -math.sin(val * math.pi) * amount;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: child,
    );
  }
}

class Float extends StatelessWidget {
  final Widget child;
  const Float({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 4),
      reverse: true,
      builder: (context, val, child) {
        final offset = math.sin(val * 2 * math.pi) * 6;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: child,
    );
  }
}

class Spin extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final bool reverse;
  const Spin({super.key, required this.child, this.duration = const Duration(seconds: 3), this.reverse = false});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: duration,
      builder: (context, val, child) {
        final angle = reverse ? -val * 2 * math.pi : val * 2 * math.pi;
        return Transform.rotate(angle: angle, child: child);
      },
      child: child,
    );
  }
}

class Shake extends StatelessWidget {
  final Widget child;
  const Shake({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(milliseconds: 500),
      builder: (context, val, child) {
        final offset = math.sin(val * 4 * math.pi) * 3;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: child,
    );
  }
}

class Glitch extends StatelessWidget {
  final Widget child;
  const Glitch({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(milliseconds: 1000),
      builder: (context, val, child) {
        double x = 0;
        double y = 0;
        double opacity = 1.0;
        if (val > 0.2 && val < 0.4) { x = -2; y = 2; opacity = 0.8; }
        if (val > 0.4 && val < 0.6) { x = 2; y = -2; opacity = 0.8; }
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: Offset(x, y), child: child),
        );
      },
      child: child,
    );
  }
}

class Shimmer extends StatelessWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 2),
      builder: (context, val, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.4), Colors.white.withOpacity(0)],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + (val * 3), -0.5),
              end: Alignment(1.0 + (val * 3), 0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: child,
    );
  }
}

// --- 2. THE 35 COMPONENTS (ADAPTED) ---

class LifePathPin extends StatelessWidget {
  const LifePathPin({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Ping(child: Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.mutedGold.withOpacity(0.3), shape: BoxShape.circle))),
          Bounce(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppColors.structuralBrown, shape: BoxShape.circle),
              child: const Icon(Icons.gps_fixed, color: AppColors.mutedGold, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ApartmentMarker extends StatelessWidget {
  const ApartmentMarker({super.key});
  @override
  Widget build(BuildContext context) {
    return Float(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.structuralBrown, width: 2), borderRadius: BorderRadius.circular(4)),
            child: const Icon(Icons.home, color: AppColors.structuralBrown, size: 16),
          ),
          Container(width: 2, height: 10, color: AppColors.structuralBrown),
        ],
      ),
    );
  }
}

class ActiveRoute extends StatelessWidget {
  const ActiveRoute({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 6,
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.structuralBrown.withOpacity(0.1), borderRadius: BorderRadius.circular(3)),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return LoopAnimation(
              duration: const Duration(seconds: 3),
              builder: (ctx, val, child) {
                double start = val * constraints.maxWidth * 1.5 - (constraints.maxWidth * 0.2);
                return Stack(
                  children: [
                    Positioned(
                      left: start,
                      width: constraints.maxWidth * 0.3,
                      top: 0, bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.mutedGold, borderRadius: BorderRadius.circular(3)),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class StageRadar extends StatelessWidget {
  const StageRadar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.structuralBrown.withOpacity(0.1))),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Spin(child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mutedGold.withOpacity(0.6), width: 2),
            ),
          )),
          const Icon(Icons.directions_bus, color: AppColors.structuralBrown, size: 24),
        ],
      ),
    );
  }
}

class MatchScoreRing extends StatelessWidget {
  final int score;
  const MatchScoreRing({super.key, required this.score});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 4),
      reverse: true,
      builder: (ctx, val, child) => Transform.scale(scale: 1.0 + (val * 0.05), child: child),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: 1, color: AppColors.alabaster, strokeWidth: 6)),
          SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: score / 100, color: AppColors.mutedGold, strokeWidth: 6, strokeCap: StrokeCap.round)),
          Text("$score%", style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.structuralBrown, fontSize: 16)),
        ],
      ),
    );
  }
}

class TotalCostBadge extends StatelessWidget {
  const TotalCostBadge({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.structuralBrown,
          borderRadius: BorderRadius.circular(12),
          border: const Border(bottom: BorderSide(color: AppColors.mutedGold, width: 4)),
        ),
        child: const Text("KES 45,000", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class PriceTagBounce extends StatelessWidget {
  const PriceTagBounce({super.key});
  @override
  Widget build(BuildContext context) {
    return Bounce(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.mutedGold, borderRadius: BorderRadius.circular(20)),
        child: const Text("KES 25K", style: TextStyle(color: AppColors.structuralBrown, fontWeight: FontWeight.w900, fontSize: 10)),
      ),
    );
  }
}

class PantryPin extends StatelessWidget {
  const PantryPin({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 3),
      reverse: true,
      builder: (ctx, val, child) => Transform.rotate(angle: math.sin(val * 2 * math.pi) * 0.15, alignment: Alignment.topCenter, child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.bolt, color: Colors.orange, size: 20)),
          Container(width: 2, height: 12, color: AppColors.structuralBrown.withOpacity(0.2)),
        ],
      ),
    );
  }
}

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 1),
      reverse: true,
      builder: (ctx, val, child) => Opacity(opacity: 0.4 + (val * 0.6), child: child),
      child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
    );
  }
}

class SuccessStateIndicator extends StatelessWidget {
  const SuccessStateIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return Bounce(child: const Icon(Icons.check_circle, color: AppColors.sageGreen, size: 40));
  }
}

class ErrorPinShake extends StatelessWidget {
  const ErrorPinShake({super.key});
  @override
  Widget build(BuildContext context) {
    return Shake(child: const Icon(Icons.error_outline, color: AppColors.brickRed, size: 40));
  }
}

class FavoritePop extends StatelessWidget {
  const FavoritePop({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(milliseconds: 1500),
      builder: (ctx, val, child) {
        double scale = 1.0;
        if (val < 0.2) scale = 1.0 + val; 
        else if (val < 0.4) scale = 1.2 - (val - 0.2);
        return Transform.scale(scale: scale, child: child);
      },
      child: const Icon(Icons.favorite, color: AppColors.brickRed, size: 32),
    );
  }
}

class WifiStrengthPing extends StatelessWidget {
  const WifiStrengthPing({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Ping(child: Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.structuralBrown.withOpacity(0.2), shape: BoxShape.circle))),
        const Icon(Icons.wifi, color: AppColors.structuralBrown, size: 24),
      ],
    );
  }
}

class SecureShieldGlint extends StatelessWidget {
  const SecureShieldGlint({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer(child: const Icon(Icons.verified_user, color: AppColors.sageGreen, size: 40));
  }
}

class WaterSupplyDrip extends StatelessWidget {
  const WaterSupplyDrip({super.key});
  @override
  Widget build(BuildContext context) {
    return Bounce(child: const Icon(Icons.water_drop, color: Colors.blue, size: 28));
  }
}

class CommuteCarSlider extends StatelessWidget {
  const CommuteCarSlider({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 6, width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return LoopAnimation(
              duration: const Duration(seconds: 4),
              reverse: true,
              builder: (ctx, val, child) {
                final pos = val * (constraints.maxWidth - 20);
                return Stack(children: [Positioned(left: pos, top: -10, child: const Icon(Icons.directions_car, color: AppColors.structuralBrown, size: 16))]);
              },
            );
          },
        ),
      ),
    );
  }
}

class EmptyStateGhost extends StatelessWidget {
  const EmptyStateGhost({super.key});
  @override
  Widget build(BuildContext context) {
    return Float(child: const Icon(Icons.search_off, size: 48, color: Colors.grey));
  }
}

class VibeTagPulse extends StatelessWidget {
  const VibeTagPulse({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 3),
      reverse: true,
      builder: (ctx, val, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Color.lerp(AppColors.sageGreen.withOpacity(0.1), AppColors.sageGreen.withOpacity(0.3), val), borderRadius: BorderRadius.circular(20)),
        child: child,
      ),
      child: const Text("QUIET", style: TextStyle(color: AppColors.sageGreen, fontWeight: FontWeight.w900, fontSize: 10)),
    );
  }
}

class PropertyTiltCard extends StatelessWidget {
  const PropertyTiltCard({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 5),
      reverse: true,
      builder: (ctx, val, child) => Transform(transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(math.sin(val * math.pi) * 0.1), alignment: Alignment.bottomCenter, child: child),
      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]), height: 100, width: 80),
    );
  }
}

class VerifiedBadgeStar extends StatelessWidget {
  const VerifiedBadgeStar({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.verified, color: Colors.blue, size: 16), const Spin(child: Icon(Icons.star, size: 10, color: AppColors.mutedGold))]);
  }
}

class NotifyBellRing extends StatelessWidget {
  const NotifyBellRing({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 2),
      builder: (ctx, val, child) {
        double angle = 0;
        if (val < 0.1) angle = 0.2; else if (val < 0.2) angle = -0.2;
        return Transform.rotate(angle: angle, child: child);
      },
      child: const Icon(Icons.notifications, color: AppColors.structuralBrown),
    );
  }
}

class SearchPulseBar extends StatelessWidget {
  const SearchPulseBar({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 3),
      reverse: true,
      builder: (ctx, val, child) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Color.lerp(AppColors.structuralBrown, AppColors.mutedGold, val)!)), padding: const EdgeInsets.all(8), child: child),
      child: const Icon(Icons.search, size: 18),
    );
  }
}

class DateFlipAnimation extends StatelessWidget {
  const DateFlipAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 4),
      builder: (ctx, val, child) {
        double angle = val > 0.8 ? (val - 0.8) * 5 * 2 * math.pi : 0;
        return Transform(transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(angle), alignment: Alignment.center, child: child);
      },
      child: Container(width: 50, height: 60, decoration: BoxDecoration(color: AppColors.structuralBrown, borderRadius: BorderRadius.circular(8))),
    );
  }
}

class MarketToggleAuto extends StatelessWidget {
  const MarketToggleAuto({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(width: 80, height: 30, decoration: BoxDecoration(color: AppColors.alabaster, borderRadius: BorderRadius.circular(15)));
  }
}

class PinItCTAArrow extends StatelessWidget {
  const PinItCTAArrow({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [const Text("PIN IT"), const SizedBox(width: 4), LoopAnimation(duration: const Duration(seconds: 1), builder: (ctx, val, child) => Transform.translate(offset: Offset(val * 5, 0), child: Opacity(opacity: 1.0 - val, child: child)), child: const Icon(Icons.arrow_forward, size: 16))]);
  }
}

class NetworkErrorGlitch extends StatelessWidget {
  const NetworkErrorGlitch({super.key});
  @override
  Widget build(BuildContext context) {
    return Glitch(child: const Icon(Icons.wifi_off, color: AppColors.brickRed));
  }
}

class ServerErrorCloud extends StatelessWidget {
  const ServerErrorCloud({super.key});
  @override
  Widget build(BuildContext context) {
    return Float(child: const Icon(Icons.cloud_off, color: AppColors.brickRed));
  }
}

class AccessDeniedLock extends StatelessWidget {
  const AccessDeniedLock({super.key});
  @override
  Widget build(BuildContext context) {
    return Shake(child: const Icon(Icons.lock, color: AppColors.brickRed));
  }
}

class MaintenanceSign extends StatelessWidget {
  const MaintenanceSign({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(duration: const Duration(seconds: 2), reverse: true, builder: (ctx, val, child) => Transform.rotate(angle: math.sin(val * 2 * math.pi) * 0.2, child: child), child: const Icon(Icons.construction, color: AppColors.mutedGold));
  }
}

class MissingDataGhost extends StatelessWidget {
  const MissingDataGhost({super.key});
  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: 0.5, child: const Icon(Icons.file_present, color: AppColors.structuralBrown));
  }
}

class OfficePinBounce extends StatelessWidget {
  const OfficePinBounce({super.key});
  @override
  Widget build(BuildContext context) {
    return Bounce(child: const Icon(Icons.work, color: AppColors.structuralBrown));
  }
}

class CampusPinFloat extends StatelessWidget {
  const CampusPinFloat({super.key});
  @override
  Widget build(BuildContext context) {
    return Float(child: const Icon(Icons.school, color: Colors.blue));
  }
}

class SocialPinSwing extends StatelessWidget {
  const SocialPinSwing({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(duration: const Duration(seconds: 2), reverse: true, builder: (ctx, val, child) => Transform.rotate(angle: math.sin(val * 2 * math.pi) * 0.1, alignment: Alignment.topCenter, child: child), child: const Icon(Icons.coffee, color: AppColors.mutedGold));
  }
}

class GymPinSpin extends StatelessWidget {
  const GymPinSpin({super.key});
  @override
  Widget build(BuildContext context) {
    return Spin(child: const Icon(Icons.fitness_center, color: AppColors.sageGreen));
  }
}

class ShoppingPinPing extends StatelessWidget {
  const ShoppingPinPing({super.key});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [const Icon(Icons.shopping_cart, color: AppColors.structuralBrown), const Positioned(right: 0, child: Ping(child: CircleAvatar(radius: 4, backgroundColor: AppColors.brickRed)))]);
  }
}

// --- 3. CUSTOM KEJAPIN EXTRAS ---

class AIThinkingIndicator extends StatelessWidget {
  const AIThinkingIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      duration: const Duration(seconds: 3),
      builder: (context, val, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: val * 2 * math.pi,
              child: ShaderMask(
                shaderCallback: (bounds) => SweepGradient(colors: [AppColors.mutedGold, AppColors.mutedGold.withOpacity(0)]).createShader(bounds),
                child: Container(width: 60, height: 60, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
              ),
            ),
            const Icon(Icons.auto_awesome, color: AppColors.mutedGold, size: 24),
          ],
        );
      },
    );
  }
}

class UploadingIndicator extends StatelessWidget {
  const UploadingIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Bounce(amount: 15, child: const Icon(Icons.cloud_upload_outlined, color: AppColors.structuralBrown, size: 32)),
        const SizedBox(height: 12),
        Container(
          width: 120, height: 4,
          decoration: BoxDecoration(color: AppColors.structuralBrown.withOpacity(0.1), borderRadius: BorderRadius.circular(2)),
          child: LayoutBuilder(builder: (context, constraints) {
            return LoopAnimation(
              duration: const Duration(seconds: 2),
              builder: (context, val, child) {
                return Stack(children: [Positioned(left: (val * 1.5 - 0.5) * constraints.maxWidth, width: constraints.maxWidth * 0.5, top: 0, bottom: 0, child: Container(decoration: BoxDecoration(color: AppColors.mutedGold, borderRadius: BorderRadius.circular(2))))]);
              },
            );
          }),
        ),
      ],
    );
  }
}
