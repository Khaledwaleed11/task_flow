import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EditTaskCompletionStatus extends StatelessWidget {
  final bool isCompleted;

  const EditTaskCompletionStatus({
    super.key,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground
            : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppColors.darkSurface
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(
                alpha: 0.1,
              )
                  : AppColors.warning.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isCompleted
                  ? AppColors.success
                  : AppColors.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completion Status',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: 3),
                Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurface
                    : AppColors.border,
              ),
            ),
            child: const Text(
              'Read only',
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}