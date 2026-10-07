import 'package:flutter/material.dart';

import '../../domain/entities/project_entity.dart';

class ProjectDetailsHero extends StatelessWidget {
  final ProjectEntity project;
  final int totalTasks;
  final int completedTasks;
  final double progress;

  const ProjectDetailsHero({
    super.key,
    required this.project,
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final percentage = (progress * 100).round();

    final heroTextColor = colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primaryContainer, colorScheme.primary],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.16 : 0.20,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: heroTextColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: heroTextColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: heroTextColor,
                  size: 27,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: heroTextColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '$percentage% complete',
                  style: TextStyle(
                    color: heroTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            project.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: heroTextColor,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),

          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 8),

            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: heroTextColor.withValues(alpha: 0.72),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 22),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: heroTextColor.withValues(alpha: 0.16),
              valueColor: AlwaysStoppedAnimation<Color>(heroTextColor),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Text(
                '$completedTasks of $totalTasks tasks completed',
                style: TextStyle(
                  color: heroTextColor.withValues(alpha: 0.72),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Text(
                '$percentage%',
                style: TextStyle(
                  color: heroTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
