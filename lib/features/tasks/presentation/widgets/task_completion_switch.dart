import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TaskCompletionSwitch extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool> onChanged;

  const TaskCompletionSwitch({
    super.key,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final color = isCompleted
        ? AppColors.success
        : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 200,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(
          alpha: isDark ? 0.12 : 0.07,
        )
            : isDark
            ? AppColors.darkSurface
            : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? AppColors.success
              : isDark
              ? AppColors.darkTextSecondary
              .withValues(alpha: 0.12)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(
                alpha: 0.14,
              )
                  : isDark
                  ? AppColors.darkCard
                  : AppColors.background,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: color,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted
                      ? 'Task completed'
                      : 'Task not completed',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCompleted
                      ? 'This task is marked as completed.'
                      : 'Mark this task as completed when finished.',
                  style:
                  AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Switch(
            value: isCompleted,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}