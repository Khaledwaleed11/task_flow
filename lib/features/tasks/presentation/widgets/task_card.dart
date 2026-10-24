
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final bool isActionLoading;
  final bool showActions;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.isActionLoading = false,
    this.showActions = true,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.7),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TaskStatusIndicator(
                  task: task,
                  isActionLoading: isActionLoading,
                  onToggle: onToggle,
                ),
                const SizedBox(width: 14),
                Expanded(child: _TaskContent(task: task)),
                if (showActions) ...[
                  const SizedBox(width: 8),
                  _TaskMenu(
                    isEnabled: !isActionLoading,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskStatusIndicator extends StatelessWidget {
  final TaskEntity task;
  final bool isActionLoading;
  final VoidCallback? onToggle;

  const _TaskStatusIndicator({
    required this.task,
    required this.isActionLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isActionLoading) {
      return SizedBox(
        width: 27,
        height: 27,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    final statusColor = task.isCompleted
        ? colorScheme.tertiary
        : colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: task.isCompleted ? colorScheme.tertiary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: statusColor, width: 2),
          boxShadow: task.isCompleted
              ? [
            BoxShadow(
              color: colorScheme.tertiary.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: task.isCompleted
              ? Icon(
            Icons.check_rounded,
            key: const ValueKey('completed'),
            color: colorScheme.onTertiary,
            size: 18,
          )
              : const SizedBox(key: ValueKey('pending')),
        ),
      ),
    );
  }
}

class _TaskContent extends StatelessWidget {
  final TaskEntity task;

  const _TaskContent({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final titleColor = task.isCompleted
        ? colorScheme.onSurfaceVariant
        : colorScheme.onSurface;

    final secondaryColor = colorScheme.onSurfaceVariant;

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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.35,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: titleColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _PriorityBadge(priority: task.priority),
          ],
        ),
        if (task.description.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary.copyWith(
              fontSize: 12.5,
              height: 1.45,
              color: task.isCompleted
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : secondaryColor,
              decoration: task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ],
        const SizedBox(height: 13),
        Row(
          children: [
            _MetaItem(
              icon: Icons.calendar_today_outlined,
              label: _formatDate(task.createdAt),
            ),
            const SizedBox(width: 12),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            _StatusLabel(isCompleted: task.isCompleted),
          ],
        ),
        if (task.dueDate != null) ...[
          const SizedBox(height: 14),
          _DeadlineInfo(
            dueDate: task.dueDate!,
            isCompleted: task.isCompleted,
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DeadlineInfo extends StatefulWidget {
  final DateTime dueDate;
  final bool isCompleted;

  const _DeadlineInfo({
    required this.dueDate,
    required this.isCompleted,
  });

  @override
  State<_DeadlineInfo> createState() => _DeadlineInfoState();
}

class _DeadlineInfoState extends State<_DeadlineInfo> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _DeadlineInfo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dueDate != widget.dueDate) {
      _now = DateTime.now();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.isCompleted) return;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;

      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dueDate = widget.dueDate;
    final isExpired = !widget.isCompleted && !_now.isBefore(dueDate);
    final remaining = dueDate.difference(_now);

    final Color statusColor;
    final IconData icon;
    final String message;

    if (widget.isCompleted) {
      statusColor = colorScheme.tertiary;
      icon = Icons.event_available_outlined;
      message = 'Due: ${_formatDateTime(dueDate)}';
    } else if (isExpired) {
      statusColor = colorScheme.error;
      icon = Icons.warning_amber_rounded;
      message = 'Deadline expired';
    } else {
      statusColor = remaining.inHours < 24
          ? colorScheme.error
          : colorScheme.primary;
      icon = Icons.schedule_rounded;
      message =
      'Due: ${_formatDateTime(dueDate)} • ${_formatRemaining(remaining)} left';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: statusColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  String _formatRemaining(Duration duration) {
    if (duration.inDays > 0) {
      final remainingHours = duration.inHours % 24;
      return '${duration.inDays}d ${remainingHours}h';
    }

    if (duration.inHours > 0) {
      final remainingMinutes = duration.inMinutes % 60;
      return '${duration.inHours}h ${remainingMinutes}m';
    }

    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }

    return 'Less than a minute';
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final bool isCompleted;

  const _StatusLabel({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isCompleted ? colorScheme.tertiary : colorScheme.secondary;

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              isCompleted ? 'Completed' : 'Pending',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10.5,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskMenu extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TaskMenu({
    required this.isEnabled,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Task actions',
      enabled: isEnabled,
      padding: EdgeInsets.zero,
      icon: Icon(Icons.more_horiz_rounded, color: colorScheme.onSurfaceVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
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
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 11),
                Text('Edit', style: TextStyle(color: colorScheme.onSurface)),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 11),
                Text('Delete', style: TextStyle(color: colorScheme.error)),
              ],
            ),
          ),
        ];
      },
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _priorityColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            _priorityLabel(),
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

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

  String _priorityLabel() {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }
}
