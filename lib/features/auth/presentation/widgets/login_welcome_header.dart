import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class LoginWelcomeHeader extends StatelessWidget {
  const LoginWelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 30,
            letterSpacing: -0.8,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in and get back to what matters.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}