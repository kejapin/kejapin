import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../marketplace/presentation/widgets/listing_card.dart'; // For _PulseBar if available (public?) or replicate
import '../../../../core/services/efficiency_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  int _currentStep = 0;
  final _efficiencyService = EfficiencyService();

  // Data
  String _title = '';
  double _price = 0;
  String _type = 'APARTMENT';
  LatLng _location = const LatLng(-1.286389, 36.817223); // Default Nairobi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'Create Listing', showSearch: false),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            title: const Text('Basics'),
            content: FadeInUp(
              child: Column(
                children: [
                   TextField(
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    onChanged: (v) => _title = v,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (KES)', border: OutlineInputBorder()),
                    onChanged: (v) => _price = double.tryParse(v) ?? 0,
                  ),
                ],
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 1,
            title: const Text('Location'),
            content: FadeInUp(
              child: Column(
                children: [
                  const Text('Confirm your property location on the map.', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Icon(Icons.map, size: 50, color: Colors.grey)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Address: Nairobi, Kenya (Detected)', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 2,
            title: const Text('Pulse Preview'),
            content: FadeInUp(
              child: Column(
                children: [
                  const Text('HOW USERS SEE YOUR PROPERTY', style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildPulsePreview(),
                  const SizedBox(height: 24),
                  const Text('This pulse is generated based on infrastructure data at your location.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsePreview() {
    // Generate a simulated score for preview
    final efficiency = _efficiencyService.calculateScoreFromCoords(_location.latitude, _location.longitude, {});
    
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: BorderRadius.circular(30),
      color: AppColors.structuralBrown,
      opacity: 0.05,
      child: Column(
        children: [
          Text(efficiency.efficiencyLabel.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mutedGold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: efficiency.categories.values.map((v) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 10 + (v * 40),
                decoration: BoxDecoration(color: AppColors.structuralBrown, borderRadius: BorderRadius.circular(10)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
