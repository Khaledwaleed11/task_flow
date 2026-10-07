import 'package:flutter/material.dart';

import '../../../projects/domain/entities/project_entity.dart';

class ProjectDetailsHeader extends StatelessWidget {
  final ProjectEntity project;
  final int totalTasks;
  final int completedTasks;

  const ProjectDetailsHeader({
    super.key,
    required this.project,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get progress {
    if (totalTasks == 0) {
      return 0;
    }

    return completedTasks / totalTasks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progressPercentage = (progress * 100).round();

    final heroTextColor = colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: heroTextColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: heroTextColor,
                  size: 28,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: heroTextColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '$progressPercentage% Complete',
                  style: TextStyle(
                    color: heroTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            project.name,
            style: TextStyle(
              color: heroTextColor,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          if (project.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project.description,
              style: TextStyle(
                color: heroTextColor.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: heroTextColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(heroTextColor),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                '$progressPercentage%',
                style: TextStyle(
                  color: heroTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
