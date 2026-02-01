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
      child: Padding(
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.structuralBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text("RETRY ACTION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 16),
              Text(
                "Report persistent issues to:",
                style: TextStyle(fontSize: 10, color: AppColors.structuralBrown.withOpacity(0.4)),
              ),
              Text(
                "kejapinmail@gmail.com",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.structuralBrown.withOpacity(0.7)),
              ),
            ],
          ],
        ),
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

  void showErrorDialog({String? message, VoidCallback? onRetry}) {
    showDialog(
      context: this,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: KejaStateView(
            type: KejaStateType.error,
            title: "System Hitch",
            message: message ?? "We encountered an unexpected error.",
            onRetry: () {
              Navigator.pop(context);
              onRetry?.call();
            },
          ),
        ),
      ),
    );
  }
}
