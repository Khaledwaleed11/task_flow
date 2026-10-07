import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import 'auth_submit_button.dart';
import 'auth_text_field.dart';

class RegisterFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isLoading;

  final FormFieldValidator<String>? nameValidator;
  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? passwordValidator;
  final FormFieldValidator<String>? confirmPasswordValidator;

  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;

  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.isLoading,
    required this.nameValidator,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: 0.6,
          ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create your account',
            style: AppTextStyles.title.copyWith(
              fontSize: 17,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set up your workspace account in a few simple steps.',
            style: AppTextStyles.bodySecondary.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          AuthTextField(
            controller: nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            validator: nameValidator,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: emailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: passwordController,
            label: 'Password',
            hint: 'Create a password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: passwordValidator,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            prefixIcon: Icons.verified_user_outlined,
            obscureText: obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: onToggleConfirmPassword,
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            validator: confirmPasswordValidator,
          ),
          const SizedBox(height: 26),
          AuthSubmitButton(
            isLoading: isLoading,
            label: 'Create Account',
            loadingLabel: 'Creating Account...',
            icon: Icons.arrow_forward_rounded,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}