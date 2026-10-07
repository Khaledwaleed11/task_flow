import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/project_entity.dart';

class ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final int? totalTasks;
  final int? completedTasks;
  final int? pendingTasks;
  final double? progress;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.totalTasks,
    this.completedTasks,
    this.pendingTasks,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayTotalTasks = totalTasks ?? project.totalTasks;

    final displayCompletedTasks = completedTasks ?? project.completedTasks;

    final displayPendingTasks = pendingTasks ?? project.pendingTasks;

    final displayProgress =
        progress ??
        (displayTotalTasks == 0
            ? 0.0
            : displayCompletedTasks / displayTotalTasks);

    final safeProgress = displayProgress.clamp(0.0, 1.0);

    final percentage = (safeProgress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.folder_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            project.description.isEmpty
                                ? 'No description'
                                : project.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 12.5,
                              height: 1.4,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (showActions)
                      PopupMenuButton<String>(
                        tooltip: 'Project actions',
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_horiz_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit?.call();
                          }

                          if (value == 'delete') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: colorScheme.onSurface,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProjectMetric(
                          icon: Icons.task_alt_rounded,
                          iconColor: colorScheme.tertiary,
                          value: '$displayCompletedTasks',
                          label: 'Completed',
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 36,
                        color: colorScheme.outline.withValues(alpha: 0.45),
                      ),

                      Expanded(
                        child: _ProjectMetric(
                          icon: Icons.pending_actions_rounded,
                          iconColor: colorScheme.secondary,
                          value: '$displayPendingTasks',
                          label: 'Pending',
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 36,
                        color: colorScheme.outline.withValues(alpha: 0.45),
                      ),

                      Expanded(
                        child: _ProjectMetric(
                          icon: Icons.checklist_rounded,
                          iconColor: colorScheme.primary,
                          value: '$displayTotalTasks',
                          label: 'Total',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      'Project progress',
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$percentage%',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    minHeight: 8,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        _formatDate(project.updatedAt),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return 'Updated $day/$month/$year';
  }
}

class _ProjectMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _ProjectMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: iconColor),
        const SizedBox(width: 7),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 9.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
