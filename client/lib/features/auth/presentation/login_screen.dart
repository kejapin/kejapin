import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:mesh_gradient/mesh_gradient.dart'; // Ensure you have this package or remove if unused

import '../data/auth_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _authRepository = AuthRepository();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.login(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          context.go('/marketplace');
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
                // Use a Container with gradient as fallback if MeshGradient is buggy
                : Container(
                     decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.structuralBrown,
                          const Color(0xFF5D4037),
                          AppColors.structuralBrown,
                        ],
                      ),
                    ),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 80,
                                color: Colors.white,
                                errorBuilder: (c,e,s) => const Icon(Icons.home, size: 80, color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "kejapin",
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Don't just list it. Pin it.",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: AppColors.mutedGold,
                                      letterSpacing: 2,
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
                              color: Colors.white,
                              errorBuilder: (c,e,s) => const Icon(Icons.home, size: 60, color: Colors.white),
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
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Back",
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Sign in to continue to your dashboard",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 48),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Email Address",
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
                return 'Please enter your email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: "Password",
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
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mutedGold,
                foregroundColor: AppColors.structuralBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppColors.structuralBrown)
                  : const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("OR", style: TextStyle(color: Colors.white38, fontSize: 12)),
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
                try {
                  await _authRepository.signInWithGoogle();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              icon: const Icon(Icons.login, color: Colors.white), // Simplified icon for stability
              label: const Text(
                "Continue with Google",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
              const Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.white70),
              ),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: AppColors.mutedGold,
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
