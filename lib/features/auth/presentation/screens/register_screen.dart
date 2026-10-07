import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_divider.dart';
import '../widgets/register_back_button.dart';
import '../widgets/register_brand.dart';
import '../widgets/register_form_card.dart';
import '../widgets/register_welcome_header.dart';

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
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

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

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
            authProvider.errorMessage ??
                'Failed to create account.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
  }

  void _backToLogin() {
    Navigator.of(context).pop();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 470,
                      ),
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: [
                                RegisterBackButton(
                                  onPressed: _backToLogin,
                                ),
                                const SizedBox(height: 24),
                                const RegisterBrand(),
                                const SizedBox(height: 38),
                                const RegisterWelcomeHeader(),
                                const SizedBox(height: 28),
                                RegisterFormCard(
                                  nameController: _nameController,
                                  emailController: _emailController,
                                  passwordController:
                                  _passwordController,
                                  confirmPasswordController:
                                  _confirmPasswordController,
                                  obscurePassword:
                                  _obscurePassword,
                                  obscureConfirmPassword:
                                  _obscureConfirmPassword,
                                  isLoading:
                                  authProvider.isLoading,
                                  nameValidator:
                                  _validateName,
                                  emailValidator:
                                  _validateEmail,
                                  passwordValidator:
                                  _validatePassword,
                                  confirmPasswordValidator:
                                  _validateConfirmPassword,
                                  onTogglePassword:
                                  _togglePasswordVisibility,
                                  onToggleConfirmPassword:
                                  _toggleConfirmPasswordVisibility,
                                  onSubmit: _register,
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Already have an account?',
                                        style: AppTextStyles
                                            .bodySecondary
                                            .copyWith(
                                          color: colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    TextButton(
                                      onPressed: _backToLogin,
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                        colorScheme.primary,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                        MaterialTapTargetSize
                                            .shrinkWrap,
                                      ),
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color:
                                          colorScheme.primary,
                                          fontWeight:
                                          FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const AuthDivider(),
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