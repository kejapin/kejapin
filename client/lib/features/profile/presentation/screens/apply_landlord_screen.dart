import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/profile_repository.dart';
import '../../../../core/widgets/animated_indicators.dart';
import 'package:animate_do/animate_do.dart';

class ApplyLandlordScreen extends StatefulWidget {
  const ApplyLandlordScreen({super.key});

  @override
  State<ApplyLandlordScreen> createState() => _ApplyLandlordScreenState();
}

class _ApplyLandlordScreenState extends State<ApplyLandlordScreen> {
  int _currentStep = 0;
  final _profileRepo = ProfileRepository();
  final _picker = ImagePicker();
  
  // Data
  String? _companyName;
  String? _companyBio;
  XFile? _idDocument;
  XFile? _selfie;
  bool _isSubmitting = false;

  Future<void> _pickImage(bool forSelfie) async {
    final XFile? image = await _picker.pickImage(
      source: forSelfie ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image != null) {
      setState(() {
        if (forSelfie) {
          _selfie = image;
        } else {
          _idDocument = image;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_idDocument == null || _selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required documents')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // In a real app, we would upload to Supabase Storage first.
      // For this implementation, we'll store the paths/names in the JSONB documents field.
      await _profileRepo.submitLandlordApplication(
        documents: {
          'id_document': _idDocument!.name,
          'selfie': _selfie!.name,
          'submitted_at': DateTime.now().toIso8601String(),
        },
        companyName: _companyName,
        companyBio: _companyBio,
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.structuralBrown,
            title: const Text('Congratulations!', style: TextStyle(color: AppColors.champagne)),
            content: const Text(
              'Your application has been received and auto-approved. You are now a Landlord! Admin will review your documents shortly.',
              style: TextStyle(color: AppColors.champagne),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.go('/marketplace');
                },
                child: const Text('Go to Dashboard', style: TextStyle(color: AppColors.mutedGold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'Become a Landlord', showSearch: false),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.structuralBrown,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting 
                      ? const UploadingIndicator()
                      : Text(_currentStep == 2 ? 'SUBMIT APPLICATION' : 'CONTINUE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('BACK', style: TextStyle(color: AppColors.structuralBrown)),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            title: const Text('Company'),
            content: FadeInUp(
              child: Column(
                children: [
                  const Text('Tell us about your property agency or personal brand.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _companyName = v,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Company Bio',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _companyBio = v,
                  ),
                ],
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            title: const Text('Identify'),
            content: FadeInUp(
              child: Column(
                children: [
                  const Text('Upload a clear photo of your ID or Passport.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  _buildUploadCard(
                    title: 'ID Document',
                    file: _idDocument,
                    onTap: () => _pickImage(false),
                    icon: Icons.badge_outlined,
                  ),
                ],
              ),
            ),
          ),
          Step(
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            title: const Text('Verify'),
            content: FadeInUp(
              child: Column(
                children: [
                  const Text('Take a live selfie to verify your identity.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  _buildUploadCard(
                    title: 'Live Selfie',
                    file: _selfie,
                    onTap: () => _pickImage(true),
                    icon: Icons.camera_front_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({required String title, XFile? file, required VoidCallback onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        height: 200,
        width: double.infinity,
        borderRadius: BorderRadius.circular(20),
        color: AppColors.structuralBrown.withOpacity(0.05),
        child: file != null 
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(file.path), fit: BoxFit.cover),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: AppColors.structuralBrown.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                const Text('Tap to capture', style: TextStyle(color: Colors.grey)),
              ],
            ),
      ),
    );
  }
}
