import 'package:flutter/material.dart';
import 'animated_indicators.dart';
import '../constants/app_colors.dart';

enum KejaStateType { loading, error, empty, aiProcessing, maintenance }

class KejaStateView extends StatelessWidget {
  final KejaStateType type;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const KejaStateView({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          const SizedBox(height: 24),
          if (title != null)
            Text(
              title!.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 2,
                color: AppColors.structuralBrown,
              ),
            ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.structuralBrown.withOpacity(0.6),
              ),
            ),
          ],
          if (onRetry != null && type == KejaStateType.error) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.structuralBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("RETRY ACTION"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case KejaStateType.loading:
        return const LoadingSkeleton();
      case KejaStateType.error:
        return const NetworkErrorGlitch();
      case KejaStateType.empty:
        return const EmptyStateGhost();
      case KejaStateType.aiProcessing:
        return const AIThinkingIndicator();
      case KejaStateType.maintenance:
        return const MaintenanceSign();
    }
  }
}

/// A handy extension to show loading/error overlays easily
extension KejaStateOverlay on BuildContext {
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const UploadingIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
