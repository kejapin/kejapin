import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import 'package:animate_do/animate_do.dart';

class PropertyReviewScreen extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const PropertyReviewScreen({super.key, required this.propertyId, required this.propertyName});

  @override
  State<PropertyReviewScreen> createState() => _PropertyReviewScreenState();
}

class _PropertyReviewScreenState extends State<PropertyReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: CustomAppBar(title: 'Review ${widget.propertyName}', showSearch: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FadeInDown(
              child: const Text(
                'How was your stay?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            _buildStarRating(),
            const SizedBox(height: 32),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Tell us about the management, wifi, and neighborhood...',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _rating == 0 || _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.structuralBrown,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT REVIEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => setState(() => _rating = index + 1),
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: AppColors.mutedGold,
            size: 40,
          ),
        );
      }),
    );
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Your review is live.')));
      Navigator.pop(context);
    }
  }
}
