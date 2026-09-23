import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final bool isActionLoading;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.isActionLoading = false,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckbox(
                isDark: isDark,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _buildContent(
                  isDark: isDark,
                ),
              ),

              const SizedBox(width: 8),

              _buildMenu(
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool isDark,
  }) {
    if (isActionLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      );
    }

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: task.isCompleted
              ? AppColors.success
              : Colors.transparent,
          border: Border.all(
            color: task.isCompleted
                ? AppColors.success
                : isDark
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: task.isCompleted
            ? const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 17,
        )
            : null,
      ),
    );
  }

  Widget _buildContent({
    required bool isDark,
  }) {
    final titleColor = task.isCompleted
        ? isDark
        ? AppColors.darkTextSecondary
        : AppColors.textTertiary
        : isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: titleColor,
                ),
              ),
            ),

            const SizedBox(width: 8),

            _PriorityBadge(
              priority: task.priority,
              isDark: isDark,
            ),
          ],
        ),

        if (task.description.trim().isNotEmpty) ...[
          const SizedBox(height: 7),

          Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary.copyWith(
              color: task.isCompleted
                  ? isDark
                  ? AppColors.darkTextSecondary
                  .withValues(alpha: 0.65)
                  : AppColors.textTertiary
                  : isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ],

        const SizedBox(height: 11),

        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textTertiary,
            ),

            const SizedBox(width: 5),

            Text(
              _formatDate(task.createdAt),
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textTertiary,
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              task.isCompleted
                  ? 'Completed'
                  : 'Pending',
              style: AppTextStyles.caption.copyWith(
                color: task.isCompleted
                    ? AppColors.success
                    : AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenu({
    required bool isDark,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Task actions',
      enabled: !isActionLoading,
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;

          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                ),
                SizedBox(width: 10),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                SizedBox(width: 10),
                Text('Delete'),
              ],
            ),
          ),
        ];
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isDark;

  const _PriorityBadge({
    required this.priority,
    required this.isDark,
  });

  String get _text {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';

      case TaskPriority.medium:
        return 'Medium';

      case TaskPriority.high:
        return 'High';
    }
  }

  Color get _color {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.success;

      case TaskPriority.medium:
        return AppColors.warning;

      case TaskPriority.high:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(
          alpha: isDark ? 0.16 : 0.10,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _color.withValues(
            alpha: isDark ? 0.25 : 0.12,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}