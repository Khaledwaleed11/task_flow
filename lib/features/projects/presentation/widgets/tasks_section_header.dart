import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class TasksSectionHeader extends StatelessWidget {
  final int taskCount;

  const TasksSectionHeader({super.key, required this.taskCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(
          'Tasks',
          style: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$taskCount',
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
