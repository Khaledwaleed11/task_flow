import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();

    super.dispose();
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

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Failed to login.'),
            backgroundColor: AppColors.error,
          ),
        );
    }
  }

  Future<void> _openRegister() async {
    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

    if (!mounted || registered != true) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please sign in.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.12 : 0.07,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
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
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
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
                                _LoginBrand(),
                                const SizedBox(height: 42),
                                _WelcomeHeader(),
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
                                        'Sign in to your account',
                                        style: AppTextStyles.title.copyWith(
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Enter your details to access your workspace.',
                                        style: AppTextStyles.bodySecondary,
                                      ),
                                      const SizedBox(height: 24),
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
                                        hint: 'Enter your password',
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
                                      const SizedBox(height: 26),
                                      AuthSubmitButton(
                                        isLoading: authProvider.isLoading,
                                        label: 'Sign In',
                                        loadingLabel: 'Signing In...',
                                        icon: Icons.arrow_forward_rounded,
                                        onPressed: _login,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                AuthFooter(
                                  message: "Don't have an account?",
                                  actionLabel: 'Create Account',
                                  onPressed: _openRegister,
                                ),
                                const SizedBox(height: 22),
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

class _LoginBrand extends StatelessWidget {
  const _LoginBrand();

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
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
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

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 30,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in and get back to what matters.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}
