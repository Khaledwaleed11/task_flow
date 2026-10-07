import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class RegisterWelcomeHeader extends StatelessWidget {
  const RegisterWelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 30,
            letterSpacing: -0.8,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start organizing your work with TaskFlow.',
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