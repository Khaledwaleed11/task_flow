import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProjectsTopBar extends StatelessWidget {
  final int projectCount;
  final VoidCallback onBack;
  final VoidCallback onCreate;

  const ProjectsTopBar({
    super.key,
    required this.projectCount,
    required this.onBack,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: AppColors.textPrimary,
                fixedSize: const Size(44, 44),
                side: BorderSide(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.border,
                ),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onCreate,
              tooltip: 'New project',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(
                Icons.add_rounded,
                size: 21,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Projects',
          style: AppTextStyles.display.copyWith(
            fontSize: 32,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              projectCount == 0
                  ? 'No projects in your workspace yet'
                  : '$projectCount ${projectCount == 1 ? 'project' : 'projects'} in your workspace',
              style: AppTextStyles.bodySecondary,
            ),
            if (projectCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Workspace',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ],
    );
  }
}