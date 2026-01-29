import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';

class VideoHeroBackground extends StatefulWidget {
  final String videoAsset;
  final String fallbackImageAsset;

  const VideoHeroBackground({
    super.key,
    required this.videoAsset,
    required this.fallbackImageAsset,
  });

  @override
  State<VideoHeroBackground> createState() => _VideoHeroBackgroundState();
}

class _VideoHeroBackgroundState extends State<VideoHeroBackground> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.videoAsset);
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0.0); // Mute for background
      await _controller.play();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Error initializing video: $e");
      // Fallback to image is handled by _isInitialized being false
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
      fit: StackFit.expand,
      children: [
        // Background: Video or Fallback Image
        if (_isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          )
        else
          Image.asset(
            widget.fallbackImageAsset,
            fit: BoxFit.cover,
          ),

        // Vignette Effect & Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.transparent,
                AppColors.structuralBrown.withOpacity(0.3),
                AppColors.structuralBrown.withOpacity(0.8),
              ],
              stops: const [0.2, 0.6, 1.0],
            ),
          ),
        ),
        
        // Additional Linear Gradient for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.structuralBrown.withOpacity(0.6),
                AppColors.structuralBrown.withOpacity(0.4),
                AppColors.structuralBrown.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
