import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../projects/domain/entities/project_entity.dart';

class ProjectInfoCard extends StatelessWidget {
  final ProjectEntity project;

  const ProjectInfoCard({
    super.key,
    required this.project,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Information',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created',
                  value: _formatDate(project.createdAt),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoItem(
                  icon: Icons.update_rounded,
                  label: 'Updated',
                  value: _formatDate(project.updatedAt),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _InfoItem(
            icon: Icons.checklist_rounded,
            label: 'Total Tasks',
            value: '${project.totalTasks}',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}