import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminUsersErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminUsersErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.error.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.error,
              size: 29,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Unable to load users',
            style: AppTextStyles.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 130,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}