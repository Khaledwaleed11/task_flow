import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkSurface : AppColors.border,
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
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.folder_rounded,
                        color: AppColors.primary,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showActions)
                      PopupMenuButton<String>(
                        tooltip: 'Project actions',
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.textSecondary,
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
                          return const [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit'),
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
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Delete'),
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
                    color: isDark
                        ? AppColors.darkBackground
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ProjectMetric(
                          icon: Icons.task_alt_rounded,
                          iconColor: AppColors.success,
                          value: '$displayCompletedTasks',
                          label: 'Completed',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.divider,
                      ),
                      Expanded(
                        child: _ProjectMetric(
                          icon: Icons.pending_actions_rounded,
                          iconColor: AppColors.warning,
                          value: '$displayPendingTasks',
                          label: 'Pending',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.divider,
                      ),
                      Expanded(
                        child: _ProjectMetric(
                          icon: Icons.checklist_rounded,
                          iconColor: AppColors.primary,
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
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: AppColors.primaryDark,
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
                    backgroundColor: AppColors.primarySoft,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(project.updatedAt),
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
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
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(fontSize: 9.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
