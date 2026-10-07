import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: colorScheme.error,
              size: 28,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Something went wrong',
            style: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            style: AppTextStyles.bodySecondary.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.outline),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
