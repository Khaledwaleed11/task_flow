import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';

class EditTaskPrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onChanged;

  const EditTaskPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppTextStyles.title.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Choose how important this task is.',
          style:
          AppTextStyles.bodySecondary.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _PriorityOption(
                priority: TaskPriority.low,
                label: 'Low',
                icon:
                Icons.keyboard_arrow_down_rounded,
                selected:
                selectedPriority ==
                    TaskPriority.low,
                onTap: () {
                  onChanged(
                    TaskPriority.low,
                  );
                },
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _PriorityOption(
                priority: TaskPriority.medium,
                label: 'Medium',
                icon: Icons.remove_rounded,
                selected:
                selectedPriority ==
                    TaskPriority.medium,
                onTap: () {
                  onChanged(
                    TaskPriority.medium,
                  );
                },
                isDark: isDark,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _PriorityOption(
                priority: TaskPriority.high,
                label: 'High',
                icon:
                Icons.keyboard_arrow_up_rounded,
                selected:
                selectedPriority ==
                    TaskPriority.high,
                onTap: () {
                  onChanged(
                    TaskPriority.high,
                  );
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final TaskPriority priority;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _PriorityOption({
    required this.priority,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  Color get _color {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.success;

      case TaskPriority.medium:
        return AppColors.warning;

      case TaskPriority.high:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? _color.withValues(
            alpha: isDark ? 0.14 : 0.07,
          )
              : isDark
              ? AppColors.darkSurface
              : AppColors.surface,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _color
                : isDark
                ? AppColors.darkTextSecondary
                .withValues(alpha: 0.12)
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? _color
                  : isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? _color
                    : isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}