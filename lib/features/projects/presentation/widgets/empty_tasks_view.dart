import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EmptyTasksView extends StatelessWidget {
  const EmptyTasksView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark
                ? 0.3
                : 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No tasks yet',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Start by adding your first task to this project.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}