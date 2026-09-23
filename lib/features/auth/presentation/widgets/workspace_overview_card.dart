import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WorkspaceOverviewCard extends StatelessWidget {
  final int projectCount;

  const WorkspaceOverviewCard({
    super.key,
    required this.projectCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.2,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Workspace',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  projectCount == 0
                      ? 'No projects yet'
                      : '$projectCount '
                      '${projectCount == 1 ? 'project' : 'projects'} '
                      'in your workspace',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.78,
                    ),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }
}