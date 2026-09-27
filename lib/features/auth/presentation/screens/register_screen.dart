import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Please enter your name.';
    }

    if (name.length < 2) {
      return 'Name must be at least 2 characters.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Please enter your email.';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter your password.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please confirm your password.';
    }

    if (password != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to create account.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
  }

  void _backToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -110,
            child: Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.12 : 0.07,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            right: -130,
            child: Container(
              width: 330,
              height: 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySoft.withValues(
                  alpha: isDark ? 0.08 : 0.7,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                    onPressed: _backToLogin,
                                    tooltip: 'Back',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .cardColor,
                                      foregroundColor: AppColors.textPrimary,
                                      fixedSize: const Size(44, 44),
                                      side: BorderSide(
                                        color: isDark
                                            ? AppColors.darkSurface
                                            : AppColors.border,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 21,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const _RegisterBrand(),
                                const SizedBox(height: 38),
                                const _RegisterHeader(),
                                const SizedBox(height: 28),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.darkSurface
                                          : AppColors.border,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.12 : 0.035,
                                        ),
                                        blurRadius: 35,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Create your account',
                                        style: AppTextStyles.title.copyWith(
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Set up your workspace account in a few simple steps.',
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                      const SizedBox(height: 24),
                                      AuthTextField(
                                        controller: _nameController,
                                        label: 'Full Name',
                                        hint: 'Enter your full name',
                                        prefixIcon:
                                            Icons.person_outline_rounded,
                                        validator: _validateName,
                                      ),
                                      const SizedBox(height: 18),
                                      AuthTextField(
                                        controller: _emailController,
                                        label: 'Email',
                                        hint: 'Enter your email',
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: _validateEmail,
                                      ),
                                      const SizedBox(height: 18),
                                      AuthTextField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hint: 'Create a password',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                        ),
                                        validator: _validatePassword,
                                      ),
                                      const SizedBox(height: 18),
                                      AuthTextField(
                                        controller: _confirmPasswordController,
                                        label: 'Confirm Password',
                                        hint: 'Re-enter your password',
                                        prefixIcon:
                                            Icons.verified_user_outlined,
                                        obscureText: _obscureConfirmPassword,
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                        ),
                                        validator: _validateConfirmPassword,
                                      ),
                                      const SizedBox(height: 26),
                                      AuthSubmitButton(
                                        isLoading: authProvider.isLoading,
                                        label: 'Create Account',
                                        loadingLabel: 'Creating Account...',
                                        icon: Icons.arrow_forward_rounded,
                                        onPressed: _register,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account?',
                                      style: AppTextStyles.bodySecondary,
                                    ),
                                    TextButton(
                                      onPressed: _backToLogin,
                                      child: const Text('Sign In'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? AppColors.darkCard
                                            : AppColors.divider,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        'TASKFLOW',
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: isDark
                                            ? AppColors.darkCard
                                            : AppColors.divider,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterBrand extends StatelessWidget {
  const _RegisterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'TaskFlow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 30,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start organizing your work with TaskFlow.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
