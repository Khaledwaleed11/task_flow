import 'package:flutter/material.dart';

import 'admin_stat_card.dart';

class AdminStatisticsGrid extends StatelessWidget {
  final int projectsCount;
  final int tasksCount;
  final int completedTasksCount;

  const AdminStatisticsGrid({
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
          child: AdminStatCard(
            icon: Icons.folder_copy_outlined,
            value: '$projectsCount',
            label: 'Projects',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AdminStatCard(
            icon: Icons.checklist_rounded,
            value: '$tasksCount',
            label: 'Tasks',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AdminStatCard(
            icon: Icons.task_alt_rounded,
            value: '$completedTasksCount',
            label: 'Completed',
          ),
        ),
      ],
    );
  }
}