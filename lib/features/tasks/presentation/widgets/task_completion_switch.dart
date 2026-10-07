import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    final statusColor = isCompleted
        ? colorScheme.tertiary
        : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.tertiary.withValues(alpha: 0.10)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? colorScheme.tertiary
              : colorScheme.outline.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? colorScheme.tertiary.withValues(alpha: 0.14)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: statusColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'Task completed' : 'Task not completed',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCompleted
                      ? 'This task is marked as completed.'
                      : 'Mark this task as completed when finished.',
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: isCompleted, onChanged: onChanged),
        ],
      ),
    );
  }
}
