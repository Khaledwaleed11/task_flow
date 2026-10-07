import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AdminUsersSectionHeader extends StatelessWidget {
  const AdminUsersSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Members',
          style: AppTextStyles.headline.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'People with access to your workspace',
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}