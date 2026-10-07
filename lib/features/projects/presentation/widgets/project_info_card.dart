import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../projects/domain/entities/project_entity.dart';

class ProjectInfoCard extends StatelessWidget {
  final ProjectEntity project;

  const ProjectInfoCard({super.key, required this.project});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Information',
            style: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
