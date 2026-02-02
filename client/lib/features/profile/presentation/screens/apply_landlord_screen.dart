import 'dart:math' as math;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/animated_indicators.dart';
import '../../../../core/widgets/keja_state_view.dart';
import '../../data/profile_repository.dart';
import '../../../../core/services/supabase_storage_service.dart';

class ApplyLandlordScreen extends StatefulWidget {
  const ApplyLandlordScreen({super.key});

  @override
  State<ApplyLandlordScreen> createState() => _ApplyLandlordScreenState();
}

class _ApplyLandlordScreenState extends State<ApplyLandlordScreen> {
  int _currentStep = 0;
  final _profileRepo = ProfileRepository();
  final _storageService = SupabaseStorageService();
  final _picker = ImagePicker();
  
  // Controllers
  final _fullNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _kraPinController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyBioController = TextEditingController();
  final _payoutDetailsController = TextEditingController();

  // Selection Data
  String _businessRole = 'OWNER'; // OWNER, AGENT, CARETAKER
  String _proofType = 'UTILITY_BILL'; // UTILITY_BILL, REG_CERT, AUTHORITY_LETTER
  String _payoutMethod = 'MPESA'; // MPESA, BANK
  
  // File Data
  XFile? _idFront;
  XFile? _idBack;
  XFile? _selfie;
  XFile? _proofDocument;
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _kraPinController.dispose();
    _companyNameController.dispose();
    _companyBioController.dispose();
    _payoutDetailsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(
      source: type == 'SELFIE' ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
    );
    if (image != null) {
      setState(() {
        if (type == 'SELFIE') _selfie = image;
        else if (type == 'ID_FRONT') _idFront = image;
        else if (type == 'ID_BACK') _idBack = image;
        else if (type == 'PROOF') _proofDocument = image;
      });
    }
  }

  bool _validateStep() {
    if (_currentStep == 0) {
      if (_fullNameController.text.isEmpty) return _error("Legal name is required");
      if (_idNumberController.text.isEmpty) return _error("ID Number is required");
      if (_phoneController.text.isEmpty) return _error("Phone number is required");
    } else if (_currentStep == 1) {
      if (_kraPinController.text.isEmpty) return _error("KRA PIN is required for verification");
    } else if (_currentStep == 2) {
      if (_idFront == null) return _error("ID Front is required");
      if (_idBack == null) return _error("ID Back is required");
      if (_selfie == null) return _error("Live selfie image is required");
      if (_proofDocument == null) return _error("Proof of association is required");
    } else if (_currentStep == 3) {
      if (_payoutDetailsController.text.isEmpty) return _error("Payout details are required");
    }
    return true;
  }

  bool _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
    return false;
  }

  Future<void> _checkExistingPartnerStatus() async {
    setState(() => _isSubmitting = true);
    try {
      // Direct fetch from Supabase (source of truth)
      final profile = await _profileRepo.getProfile();
      
      if (mounted) {
        if (profile.role == 'LANDLORD' || profile.role == 'AGENT' || profile.role == 'ADMIN') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Partner status confirmed! Redirecting to dashboard..."),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) context.go('/landlord-dashboard');
          });
        } else if (profile.vStatus == 'PENDING') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Your application is still PENDING verification. Please wait for approval."),
              backgroundColor: AppColors.mutedGold,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No partner record found. Please proceed with the application."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      // 1. Upload Documents to Supabase Storage
      final userId = _profileRepo.supabase.auth.currentUser?.id;
      if (userId == null) throw Exception("User not logged in");

      // We'll use a folder for each user in the 'verification-documents' bucket
      final String idFrontUrl = await _storageService.uploadFile(
        bucket: 'verification-documents',
        file: File(_idFront!.path),
        path: '$userId/id_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final String idBackUrl = await _storageService.uploadFile(
        bucket: 'verification-documents',
        file: File(_idBack!.path),
        path: '$userId/id_back_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final String selfieUrl = await _storageService.uploadFile(
        bucket: 'verification-documents',
        file: File(_selfie!.path),
        path: '$userId/selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final String proofUrl = await _storageService.uploadFile(
        bucket: 'verification-documents',
        file: File(_proofDocument!.path),
        path: '$userId/proof_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 2. Submit Data to Backend
      await _profileRepo.submitLandlordApplication(
        documents: {
          'id_front': idFrontUrl,
          'id_back': idBackUrl,
          'selfie': selfieUrl,
          'proof_document': proofUrl,
          'proof_type': _proofType,
          'submitted_at': DateTime.now().toIso8601String(),
        },
        companyName: _companyNameController.text,
        companyBio: _companyBioController.text,
        nationalId: _idNumberController.text,
        kraPin: _kraPinController.text,
        businessRole: _businessRole,
        payoutMethod: _payoutMethod,
        payoutDetails: _payoutDetailsController.text,
        phoneNumber: _phoneController.text,
      );

      // Note: We removed the auto-approval block. 
      // User must now wait for admin to approve from the Verification Hub.

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PartnerCongratulationsCard(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Upload failed: $e\nMake sure your Supabase Bucket "verification-documents" is created and public.'), backgroundColor: Colors.redAccent)
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
      appBar: const CustomAppBar(title: 'PARTNER PROGRAM', showSearch: false),
      body: Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.structuralBrown)),
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_validateStep()) {
              if (_currentStep < 3) setState(() => _currentStep++);
              else _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) => _buildControls(details),
          steps: [
            _buildIdentityStep(),
            _buildVerificationStep(),
            _buildDocumentStep(),
            _buildFinanceStep(),
          ],
        ),
      ),
    );
  }

  Step _buildIdentityStep() {
    return Step(
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      title: const Text('ID'),
      content: FadeInUp(
        child: Column(
          children: [
            _buildField(_fullNameController, 'Full Legal Name', 'Must match ID/M-Pesa', Icons.person),
            _buildField(_idNumberController, 'National ID Number', '00000000', Icons.badge, keyboard: TextInputType.number),
            _buildField(_phoneController, 'Contact Phone', '0700 000 000', Icons.phone, keyboard: TextInputType.phone),
            const SizedBox(height: 16),
            _buildRoleSelector(),
          ],
        ),
      ),
    );
  }

  Step _buildVerificationStep() {
    return Step(
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      title: const Text('Keja'),
      content: FadeInUp(
        child: Column(
          children: [
            _buildField(_kraPinController, 'KRA PIN', 'A000000000X', Icons.description),
            const SizedBox(height: 16),
            _buildField(_companyNameController, 'Agency/Brand Name (Optional)', 'Kejapin Realty', Icons.business),
            const SizedBox(height: 16),
            _buildProofSelector(),
          ],
        ),
      ),
    );
  }

  Step _buildDocumentStep() {
    return Step(
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      title: const Text('Docs'),
      content: FadeInUp(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildUploadRow('ID FRONT', _idFront, () => _pickImage('ID_FRONT'), Icons.badge_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildUploadRow('ID BACK', _idBack, () => _pickImage('ID_BACK'), Icons.badge_outlined)),
              ],
            ),
            const SizedBox(height: 16),
            _buildUploadRow('LIVE SELFIE', _selfie, () => _pickImage('SELFIE'), Icons.camera_front_outlined),
            const SizedBox(height: 16),
            _buildUploadRow('ASSOCIATION PROOF (${_proofType.replaceAll('_', ' ')})', _proofDocument, () => _pickImage('PROOF'), Icons.assignment_outlined),
          ],
        ),
      ),
    );
  }

  Step _buildFinanceStep() {
    return Step(
      isActive: _currentStep >= 3,
      title: const Text('Bank'),
      content: FadeInUp(
        child: Column(
          children: [
            _buildPayoutSelector(),
            const SizedBox(height: 24),
            _buildField(
              _payoutDetailsController, 
              _payoutMethod == 'MPESA' ? 'Paybill / Till / Phone' : 'Account Details',
              _payoutMethod == 'MPESA' ? 'e.g. Paybill: 123456' : 'e.g. Bank: KCB, Acc: 9876...',
              Icons.account_balance_wallet,
              maxLines: 3
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint, IconData icon, {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.structuralBrown, size: 20),
          labelText: label, hintText: hint, border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YOUR ROLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['OWNER', 'AGENT', 'CARETAKER'].map((r) {
              final sel = _businessRole == r;
              return GestureDetector(
                onTap: () => setState(() => _businessRole = r),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: sel ? AppColors.structuralBrown : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: sel ? Colors.transparent : Colors.grey.shade200)),
                  child: Text(r, style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProofSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROOF OF ASSOCIATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Column(
          children: [
            {'val': 'UTILITY_BILL', 'label': 'Recent Utility Bill (KPLC/Water)'},
            {'val': 'REG_CERT', 'label': 'Agency Registration Cert'},
            {'val': 'AUTHORITY_LETTER', 'label': 'Letter of Authority (Caretaker)'},
          ].map((item) {
            final sel = _proofType == item['val'];
            return GestureDetector(
              onTap: () => setState(() => _proofType = item['val']!),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: sel ? AppColors.mutedGold.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: sel ? AppColors.mutedGold : Colors.grey.shade200)),
                child: Row(
                  children: [
                    Icon(sel ? Icons.check_circle : Icons.radio_button_off, color: sel ? AppColors.mutedGold : Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item['label']!, style: TextStyle(fontWeight: sel ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPayoutSelector() {
    return Row(
      children: [
        Expanded(child: _buildSelectBtn('MPESA', Icons.phone_iphone, _payoutMethod == 'MPESA')),
        const SizedBox(width: 12),
        Expanded(child: _buildSelectBtn('BANK', Icons.account_balance, _payoutMethod == 'BANK')),
      ],
    );
  }

  Widget _buildSelectBtn(String val, IconData icon, bool sel) {
    return GestureDetector(
      onTap: () => setState(() => _payoutMethod = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: sel ? AppColors.structuralBrown : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? Colors.transparent : Colors.grey.shade200)),
        child: Column(
          children: [
            Icon(icon, color: sel ? Colors.white : AppColors.structuralBrown),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(color: sel ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadRow(String label, XFile? file, VoidCallback onTap, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.2, color: Colors.grey)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 80, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: file != null ? AppColors.mutedGold : Colors.grey.shade200)),
            child: Row(
              children: [
                Icon(icon, color: file != null ? AppColors.mutedGold : Colors.grey),
                const SizedBox(width: 16),
                Expanded(child: Text(file != null ? file.name : 'Tap to upload', style: TextStyle(color: file != null ? Colors.black : Colors.grey, fontWeight: file != null ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
                if (file != null) const Icon(Icons.check_circle, color: AppColors.mutedGold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.structuralBrown, foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting ? const UploadingIndicator() : Text(_currentStep == 3 ? 'BECOME PARTNER' : 'CONTINUE', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: details.onStepCancel,
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                )
              ]
            ],
          ),
          if (_currentStep == 0) ...[
             const SizedBox(height: 20),
             TextButton(
               onPressed: _isSubmitting ? null : _checkExistingPartnerStatus,
               child: Text(
                 "Already a Partner? Tap to Verify",
                 style: GoogleFonts.workSans(
                   color: AppColors.structuralBrown,
                   fontWeight: FontWeight.bold,
                   decoration: TextDecoration.underline,
                   fontSize: 13,
                 ),
               ),
             ),
          ],
        ],
      ),
    );
  }
}

class PartnerCongratulationsCard extends StatelessWidget {
  const PartnerCongratulationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeInUp(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          borderRadius: BorderRadius.circular(40),
          color: AppColors.structuralBrown, opacity: 0.98,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, color: AppColors.mutedGold, size: 80),
              const SizedBox(height: 24),
              const Text('AUTO-VERIFIED', style: TextStyle(color: AppColors.mutedGold, letterSpacing: 4, fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 16),
              const Text('WELCOME PARTNER', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Your documents have been submitted and auto-approved for testing. You can now access the Landlord Dashboard.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.champagne, fontSize: 13, height: 1.5)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(context); context.go('/landlord-dashboard'); },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mutedGold, foregroundColor: AppColors.structuralBrown, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: const Text('GO TO DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
