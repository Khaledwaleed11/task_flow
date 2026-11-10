
import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';

class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final bool isActionLoading;
  final bool showActions;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.isActionLoading = false,
    this.showActions = true,
    this.onStart,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  DateTime _now = DateTime.now();

  late final AnimationController _pulseController;

  bool get _isExpired {
    final dueDate = widget.task.dueDate;

    return dueDate != null &&
        !widget.task.isCompleted &&
        !_now.isBefore(dueDate);
  }

  bool get _isInProgress =>
      widget.task.progressStatus == TaskProgressStatus.inProgress &&
          !widget.task.isCompleted &&
          !_isExpired;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _startTimer();
    _syncPulseAnimation();
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.task.dueDate != widget.task.dueDate ||
        oldWidget.task.isCompleted != widget.task.isCompleted ||
        oldWidget.task.progressStatus != widget.task.progressStatus) {
      _startTimer();
      _syncPulseAnimation();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _now = DateTime.now();

    if (widget.task.dueDate != null && !widget.task.isCompleted) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
          });

          _syncPulseAnimation();
        }
      });
    }
  }

  void _syncPulseAnimation() {
    if (_isInProgress) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  Color get _statusColor {
    if (widget.task.isCompleted) return AppColors.success;
    if (_isExpired) return AppColors.error;
    if (_isInProgress) return AppColors.primary;
    return AppColors.textSecondary;
  }

  String get _statusText {
    if (widget.task.isCompleted) return 'Completed';
    if (_isExpired) return 'Expired';
    if (_isInProgress) return 'In progress';
    return 'Not started';
  }

  IconData get _statusIcon {
    if (widget.task.isCompleted) return Icons.check_circle_rounded;
    if (_isExpired) return Icons.warning_amber_rounded;
    if (_isInProgress) return Icons.timelapse_rounded;
    return Icons.radio_button_unchecked_rounded;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surfaceColor =
    isDark ? AppColors.darkCard : AppColors.surface;

    final borderColor = _statusColor.withValues(
      alpha: _isInProgress ? 0.35 : 0.13,
    );

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _isInProgress ? _pulseController.value : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _isInProgress
                  ? _statusColor.withValues(alpha: 0.2 + pulse * 0.2)
                  : borderColor,
              width: _isInProgress ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.10 : 0.035,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: TextStyle(
                          color: widget.task.isCompleted
                              ? (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary)
                              : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PriorityBadge(task: widget.task),
                    if (widget.showActions) ...[
                      const SizedBox(width: 2),
                      _TaskMenu(
                        isEnabled: !widget.isActionLoading,
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatusBadge(
                      text: _statusText,
                      icon: _statusIcon,
                      color: _statusColor,
                      pulse: pulse,
                    ),
                    _MetaItem(
                      icon: Icons.calendar_today_rounded,
                      label: _formatDate(widget.task.createdAt),
                    ),
                  ],
                ),

                if (widget.task.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 13),
                  Text(
                    widget.task.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ],

                if (widget.task.dueDate != null) ...[
                  const SizedBox(height: 15),
                  _DeadlineInfo(
                    dueDate: widget.task.dueDate!,
                    isCompleted: widget.task.isCompleted,
                    now: _now,
                  ),
                ],

                if (!widget.task.isCompleted && !_isExpired) ...[
                  const SizedBox(height: 16),
                  _buildActionButton(context),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final isNotStarted =
        widget.task.progressStatus == TaskProgressStatus.notStarted;

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton.icon(
        onPressed: widget.isActionLoading
            ? null
            : isNotStarted
            ? widget.onStart
            : widget.onComplete,
        icon: widget.isActionLoading
            ? const SizedBox(
          width: 17,
          height: 17,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          isNotStarted
              ? Icons.play_arrow_rounded
              : Icons.check_circle_outline_rounded,
          size: 20,
        ),
        label: Text(
          isNotStarted ? 'Start Task' : 'Complete Task',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: isNotStarted
              ? AppColors.primary
              : AppColors.success,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final double pulse;

  const _StatusBadge({
    required this.text,
    required this.icon,
    required this.color,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09 + pulse * 0.04),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textTertiary,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DeadlineInfo extends StatelessWidget {
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime now;

  const _DeadlineInfo({
    required this.dueDate,
    required this.isCompleted,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expired = !isCompleted && !now.isBefore(dueDate);
    final remaining = dueDate.difference(now);

    final Color color;
    final IconData icon;
    final String title;
    final String message;

    if (isCompleted) {
      color = AppColors.success;
      icon = Icons.check_circle_outline_rounded;
      title = 'Completed';
      message = 'This task has been completed.';
    } else if (expired) {
      color = AppColors.error;
      icon = Icons.warning_amber_rounded;
      title = 'Deadline expired';
      message = 'The deadline has passed.';
    } else if (remaining.inHours < 24) {
      color = AppColors.warning;
      icon = Icons.schedule_rounded;
      title = 'Due soon';
      message = 'Keep an eye on the time remaining.';
    } else {
      color = AppColors.primary;
      icon = Icons.event_outlined;
      title = 'Deadline';
      message = 'You still have time to finish this task.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isCompleted && !expired)
                Text(
                  _formatRemaining(remaining),
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 15,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _formatDateTime(dueDate),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            message,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 11,
              height: 1.4,
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

    return '$day/$month/${date.year}  •  $hour:$minute';
  }

  String _formatRemaining(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (duration.inHours > 0) return '${duration.inHours}h ${minutes}m';
    if (duration.inMinutes > 0) return '${duration.inMinutes}m left';

    return 'Less than 1m';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 34,
      height: 34,
      child: PopupMenuButton<String>(
        enabled: isEnabled,
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.more_horiz_rounded,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.textSecondary,
          size: 21,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        onSelected: (value) {
          if (value == 'edit') onEdit?.call();
          if (value == 'delete') onDelete?.call();
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 19),
                SizedBox(width: 10),
                Text('Edit task'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 19,
                  color: AppColors.error,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Delete task',
                  style: TextStyle(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskEntity task;

  const _PriorityBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    final priority =
    task.priority.toString().split('.').last.toLowerCase();

    final Color color;

    switch (priority) {
      case 'high':
        color = AppColors.error;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            priority[0].toUpperCase() + priority.substring(1),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
