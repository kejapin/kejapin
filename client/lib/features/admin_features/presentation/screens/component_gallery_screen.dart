import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/animated_indicators.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/smart_dashboard_panel.dart';

class ComponentGalleryScreen extends StatelessWidget {
  const ComponentGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'COMPONENT GALLERY', showSearch: false),
      body: Stack(
        children: [
          GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
            children: [
              _GalleryItem(title: "Life-Path Pin", child: const LifePathPin()),
              _GalleryItem(title: "Apartment Marker", child: const ApartmentMarker()),
              _GalleryItem(title: "Stage Radar", child: const StageRadar()),
              _GalleryItem(title: "Match Score", child: const MatchScoreRing(score: 95)),
              _GalleryItem(title: "Success State", child: const SuccessStateIndicator()),
              _GalleryItem(title: "Error State", child: const ErrorPinShake()),
              _GalleryItem(title: "WiFi Ping", child: const WifiStrengthPing()),
              _GalleryItem(title: "AI Thinking", child: const AIThinkingIndicator()),
              _GalleryItem(title: "Uploading", child: const UploadingIndicator()),
              _GalleryItem(title: "Date Flip", child: const DateFlipAnimation()),
              _GalleryItem(title: "Notify Bell", child: const NotifyBellRing()),
              _GalleryItem(title: "Vibe Pulse", child: const VibeTagPulse()),
              _GalleryItem(title: "Dripping Water", child: const WaterSupplyDrip()),
              _GalleryItem(title: "Social Swing", child: const SocialPinSwing()),
              _GalleryItem(title: "Gym Spin", child: const GymPinSpin()),
            ],
          ),
          const SmartDashboardPanel(currentRoute: '/gallery'),
        ],
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final String title;
  final Widget child;

  const _GalleryItem({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: child)),
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
