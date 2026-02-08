import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

import '../data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import 'package:client/features/messages/data/notifications_repository.dart';
import 'widgets/password_strength_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  final _authRepository = AuthRepository();

  void _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions to continue.')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // Defaulting to TENANT role for now, can be expanded later
        final response = await _authRepository.register(
          _emailController.text,
          _passwordController.text,
          'TENANT', 
        );
        
        // If user is immediately signed in, create welcome notification
        if (response.user != null) {
          await NotificationsRepository().createNotification(
            title: 'Welcome to Kejapin! ✨',
            message: 'Your journey to finding the perfect home starts here. "Pin" your first listing to see the magic!',
            type: 'WELCOME',
          );
        }
        if (mounted) {
          context.push('/verify-email-pending?email=${_emailController.text}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Animated Gradient
          Positioned.fill(
            child: kIsWeb
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.structuralBrown,
                          const Color(0xFF5D4037),
                          AppColors.mutedGold.withOpacity(0.4),
                          AppColors.structuralBrown,
                        ],
                      ),
                    ),
                  )
                : AnimatedMeshGradient(
                    colors: [
                      AppColors.structuralBrown,
                      const Color(0xFF5D4037),
                      AppColors.mutedGold.withOpacity(0.4),
                      AppColors.structuralBrown,
                    ],
                    options: AnimatedMeshGradientOptions(speed: 2),
                  ),
          ),
          
          // Content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      children: [
                        // Left Side - Brand
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center, // Centered
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 80,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "${AppLocalizations.of(context)!.getStarted} ${AppLocalizations.of(context)!.appTitle}",
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.joinSubtitle,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.mutedGold,
                                      letterSpacing: 1,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Right Side - Glass Form
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: GlassContainer(
                              padding: const EdgeInsets.all(40),
                              constraints: const BoxConstraints(maxWidth: 450),
                              child: _buildForm(context),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile Layout
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              height: 60,
                            ),
                            const SizedBox(height: 40),
                            GlassContainer(
                              padding: const EdgeInsets.all(24),
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: _buildForm(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          
          // Back Button
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed _buildSplitLayout and _buildMobileLayout as they are integrated above

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.createAccount,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white, // Changed to white
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.registerStartJourney,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70, // Changed to white70
                ),
          ),
          const SizedBox(height: 48),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.structuralBrown, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.emailRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            onChanged: (value) => setState(() {}), // Rebuild for strength indicator
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.structuralBrown, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.passwordRequired;
              }
              if (value.length < 8) {
                return AppLocalizations.of(context)!.passwordLengthError;
              }
              return null;
            },
          ),
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            PasswordStrengthIndicator(password: _passwordController.text),
          ],
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.structuralBrown, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return AppLocalizations.of(context)!.passwordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreedToTerms = value ?? false;
                  });
                },
                activeColor: AppColors.mutedGold,
                checkColor: AppColors.structuralBrown,
                side: const BorderSide(color: Colors.white70),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.push('/terms'),
                  child: RichText(
                    text: TextSpan(
                      text: 'I agree to the ',
                      style: const TextStyle(color: Colors.white70),
                      children: [
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: TextStyle(
                            color: AppColors.mutedGold,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mutedGold,
                foregroundColor: AppColors.structuralBrown,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.structuralBrown)
                  : Text(
                      AppLocalizations.of(context)!.signUpLink,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(AppLocalizations.of(context)!.orDivider, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ),
              Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  final response = await _authRepository.signInWithGoogle();
                  if (response != null && response.user != null) {
                    await NotificationsRepository().createNotification(
                      title: 'Welcome to Kejapin! ✨',
                      message: 'Your journey starts here. Start pinning properties to your life-path to see your efficiency scores!',
                      type: 'WELCOME',
                    );
                    
                    if (mounted) {
                      context.go('/marketplace');
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              icon: Image.asset(
                'assets/images/google_logo.png',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.white),
              ), 
              label: Text(
                AppLocalizations.of(context)!.continueWithGoogle,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.alreadyHaveAccount,
                style: const TextStyle(color: Colors.white70),
              ),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  AppLocalizations.of(context)!.loginLink,
                  style: const TextStyle(
                    color: AppColors.mutedGold, // Changed to Gold
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
