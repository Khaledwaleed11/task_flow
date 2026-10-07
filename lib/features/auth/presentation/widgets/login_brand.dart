import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LoginBrand extends StatelessWidget {
  const LoginBrand({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.14 : 0.22,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'TaskFlow',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}