import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TasksErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TasksErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Something went wrong',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}