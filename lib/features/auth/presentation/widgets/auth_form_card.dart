import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'auth_submit_button.dart';
import 'auth_text_field.dart';

class AuthFormCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool isLoading;

  final String title;
  final String subtitle;
  final String submitLabel;
  final String loadingLabel;

  final FormFieldValidator<String>? emailValidator;
  final FormFieldValidator<String>? passwordValidator;

  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  const AuthFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    required this.loadingLabel,
    required this.emailValidator,
    required this.passwordValidator,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 24),
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
            hint: 'Enter your password',
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
          const SizedBox(height: 26),
          AuthSubmitButton(
            isLoading: isLoading,
            label: submitLabel,
            loadingLabel: loadingLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}