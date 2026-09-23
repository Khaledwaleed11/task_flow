import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_form_header.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();

    _emailController = TextEditingController();

    _passwordController = TextEditingController();

    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

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
      return 'Please enter a password.';
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

    if (!success) {
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
  }

  void _openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const AuthFormHeader(
                          icon: Icons.person_add_alt_1_rounded,
                          title: 'Create Account',
                          subtitle:
                              'Create an account to start managing your tasks.',
                        ),

                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.border.withValues(
                                alpha:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.3
                                    : 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              AuthTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                hint: 'Enter your name',
                                prefixIcon: Icons.person_outline,
                                validator: _validateName,
                              ),

                              const SizedBox(height: 18),

                              AuthTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter your email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateEmail,
                              ),

                              const SizedBox(height: 18),

                              AuthTextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Create a password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
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
                                hint: 'Repeat your password',
                                prefixIcon: Icons.lock_reset_outlined,
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

                              const SizedBox(height: 24),

                              AuthSubmitButton(
                                isLoading: authProvider.isLoading,
                                label: 'Create Account',
                                loadingLabel: 'Creating Account...',
                                icon: Icons.person_add_alt_1_rounded,
                                onPressed: _register,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        AuthFooter(
                          message: 'Already have an account?',
                          actionLabel: 'Sign In',
                          onPressed: _openLogin,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'TaskFlow',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
