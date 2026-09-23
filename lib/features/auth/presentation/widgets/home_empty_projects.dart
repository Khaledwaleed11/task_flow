import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomeEmptyProjects extends StatelessWidget {
  final VoidCallback onCreateProject;

  const HomeEmptyProjects({super.key, required this.onCreateProject});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border.withValues(alpha: isDarkMode ? 0.3 : 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'No projects yet',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Create your first project to start managing your tasks.',
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreateProject,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Project'),
            ),
          ),
        ],
      ),
    );
  }
}
