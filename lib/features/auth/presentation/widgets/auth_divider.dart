import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({
    super.key,
    this.label = 'TASKFLOW',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outline.withValues(
              alpha: 0.55,
            ),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outline.withValues(
              alpha: 0.55,
            ),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}