import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TasksSectionHeader extends StatelessWidget {
  final int taskCount;

  const TasksSectionHeader({
    super.key,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Tasks',
          style: AppTextStyles.title.copyWith(
            color: Theme.of(context)
                .textTheme
                .titleLarge
                ?.color,
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$taskCount',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}