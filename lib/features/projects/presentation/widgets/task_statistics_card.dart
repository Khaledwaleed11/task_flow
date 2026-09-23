import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

class TaskStatisticsCard extends StatelessWidget {
  final TaskProvider provider;

  const TaskStatisticsCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatisticItem(
            icon: Icons.checklist_rounded,
            label: 'Total',
            value: '${provider.tasks.length}',
            iconColor: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatisticItem(
            icon: Icons.check_circle_rounded,
            label: 'Completed',
            value: '${provider.completedTasksCount}',
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatisticItem(
            icon: Icons.pending_actions_rounded,
            label: 'Pending',
            value: '${provider.pendingTasksCount}',
            iconColor: AppColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),

          const SizedBox(height: 10),

          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
