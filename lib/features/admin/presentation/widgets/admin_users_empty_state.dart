import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminUsersEmptyState extends StatelessWidget {
  const AdminUsersEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: 0.6,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              color: colorScheme.primary,
              size: 35,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No users found',
            style: AppTextStyles.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'There are no registered users in your workspace yet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}