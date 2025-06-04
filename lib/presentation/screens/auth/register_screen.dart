import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isGoogleSignInAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkGoogleSignInAvailability();
  }

  Future<void> _checkGoogleSignInAvailability() async {
    final authController = ref.read(authControllerProvider);
    final isAvailable = await authController.isGoogleSignInAvailable();
    if (mounted) {
      setState(() {
        _isGoogleSignInAvailable = isAvailable;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    // Check password strength
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    
    if (!hasUppercase || !hasLowercase || !hasDigits) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }
    
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider);
      await authController.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authController = ref.read(authControllerProvider);
      await authController.signInWithGoogle();
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getPasswordStrengthColor() {
    final password = _passwordController.text;
    if (password.isEmpty) return AppColors.border;
    
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength <= 2) return AppColors.error;
    if (strength <= 3) return AppColors.warning;
    return AppColors.success;
  }

  String _getPasswordStrengthText() {
    final password = _passwordController.text;
    if (password.isEmpty) return '';
    
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength <= 2) return 'Weak';
    if (strength <= 3) return 'Medium';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Title
              Text(
                'Bellume',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 32,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create Your Account',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Register Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Register',
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Google Sign In Button (only show if available)
                    if (_isGoogleSignInAvailable) ...[
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            : const Icon(Icons.login, color: AppColors.primary),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or create account with email',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          Expanded(
                            child: Divider(color: AppColors.border),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                      onChanged: (_) => setState(() {}), // Update strength indicator
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    // Password Strength Indicator
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 16,
                            color: _getPasswordStrengthColor(),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Password Strength: ${_getPasswordStrengthText()}',
                            style: AppTextStyles.caption.copyWith(
                              color: _getPasswordStrengthColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _signUp(),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Register Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create Account'),
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Login Link
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body,
                          children: [
                            const TextSpan(text: "Already have an account? "),
                            TextSpan(
                              text: 'Sign In',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 