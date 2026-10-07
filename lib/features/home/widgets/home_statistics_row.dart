import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeStatisticsRow extends StatelessWidget {
  final int projectsCount;
  final int tasksCount;
  final int completedTasksCount;

  const HomeStatisticsRow({
    super.key,
    required this.projectsCount,
    required this.tasksCount,
    required this.completedTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatisticCard(
            icon: Icons.folder_rounded,
            label: 'Projects',
            value: '$projectsCount',
            iconColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatisticCard(
            icon: Icons.checklist_rounded,
            label: 'Tasks',
            value: '$tasksCount',
            iconColor: AppColors.info,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatisticCard(
            icon: Icons.check_circle_rounded,
            label: 'Completed',
            value: '$completedTasksCount',
            iconColor: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _StatisticCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}