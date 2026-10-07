import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';

class TaskPrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onChanged;

  const TaskPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppTextStyles.title.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose how important this task is.',
          style: AppTextStyles.bodySecondary.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        _PriorityOption(
          priority: TaskPriority.low,
          label: 'Low',
          icon: Icons.keyboard_arrow_down_rounded,
          selected: selectedPriority == TaskPriority.low,
          onTap: () => onChanged(TaskPriority.low),
        ),
        const SizedBox(height: 10),
        _PriorityOption(
          priority: TaskPriority.medium,
          label: 'Medium',
          icon: Icons.remove_rounded,
          selected: selectedPriority == TaskPriority.medium,
          onTap: () => onChanged(TaskPriority.medium),
        ),
        const SizedBox(height: 10),
        _PriorityOption(
          priority: TaskPriority.high,
          label: 'High',
          icon: Icons.keyboard_arrow_up_rounded,
          selected: selectedPriority == TaskPriority.high,
          onTap: () => onChanged(TaskPriority.high),
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

  const _PriorityOption({
    required this.priority,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  Color _priorityColor(ColorScheme colorScheme) {
    switch (priority) {
      case TaskPriority.low:
        return colorScheme.tertiary;

      case TaskPriority.medium:
        return colorScheme.secondary;

      case TaskPriority.high:
        return colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _priorityColor(colorScheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(
            alpha: 0.10,
          )
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? color
                : colorScheme.outline.withValues(
              alpha: 0.7,
            ),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 180,
              ),
              child: selected
                  ? Icon(
                Icons.check_circle_rounded,
                key: const ValueKey('selected'),
                color: color,
                size: 24,
              )
                  : Icon(
                Icons.radio_button_unchecked_rounded,
                key: const ValueKey('unselected'),
                color: colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}