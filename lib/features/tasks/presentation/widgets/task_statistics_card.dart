import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../tasks/presentation/providers/task_provider.dart';

class TaskStatisticsCard extends StatelessWidget {
  const TaskStatisticsCard({super.key});

  double _calculateProgress(int totalTasks, int completedTasks) {
    if (totalTasks == 0) {
      return 0;
    }

    return completedTasks / totalTasks;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    final totalTasks = provider.tasks.length;
    final completedTasks = provider.completedTasksCount;
    final pendingTasks = provider.pendingTasksCount;

    final progress = _calculateProgress(totalTasks, completedTasks);

    final colorScheme = Theme.of(context).colorScheme;

    final String status;
    final IconData statusIcon;
    final Color statusColor;

    if (totalTasks == 0) {
      status = 'Not Started';
      statusIcon = Icons.radio_button_unchecked_rounded;
      statusColor = Colors.grey;
    } else if (completedTasks == totalTasks) {
      status = 'Completed';
      statusIcon = Icons.check_circle_rounded;
      statusColor = Colors.green;
    } else {
      status = 'In Progress';
      statusIcon = Icons.timelapse_rounded;
      statusColor = Colors.orange;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Project Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 15, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                _ProgressRing(progress: progress, color: colorScheme.primary),

                const SizedBox(width: 24),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        totalTasks == 0
                            ? 'No tasks created yet'
                            : '$completedTasks of $totalTasks tasks completed',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _StatisticItem(
                    icon: Icons.list_alt_rounded,
                    label: 'Total',
                    value: totalTasks.toString(),
                  ),
                ),

                const _VerticalDivider(),

                Expanded(
                  child: _StatisticItem(
                    icon: Icons.check_circle_outline_rounded,
                    label: 'Completed',
                    value: completedTasks.toString(),
                  ),
                ),

                const _VerticalDivider(),

                Expanded(
                  child: _StatisticItem(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending',
                    value: pendingTasks.toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;

  const _ProgressRing({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 9,
              backgroundColor: Colors.grey.withValues(alpha: 0.08),
            ),
          ),

          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              color: color,
            ),
          ),

          Icon(
            progress == 1 ? Icons.check_rounded : Icons.flag_rounded,
            size: 24,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatisticItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 21, color: Colors.grey.shade600),

        const SizedBox(height: 7),

        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: Colors.grey.withValues(alpha: 0.15),
    );
  }
}
