import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class EmptyTasksView extends StatelessWidget {
  const EmptyTasksView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: 0.7,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: 0.10,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              color: colorScheme.primary,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No tasks yet',
            style: AppTextStyles.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Start by adding your first task to this project.',
            style: AppTextStyles.bodySecondary.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}