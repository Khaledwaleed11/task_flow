import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                fixedSize: const Size(44, 44),
                side: BorderSide(
                  color: colorScheme.outline.withValues(
                    alpha: 0.7,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                fixedSize: const Size(44, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
            color: colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 7),

        Row(
          children: [
            Expanded(
              child: Text(
                projectCount == 0
                    ? 'No projects in your workspace yet'
                    : '$projectCount ${projectCount == 1 ? 'project' : 'projects'} in your workspace',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            if (projectCount > 0) ...[
              const SizedBox(width: 10),

              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'Workspace',
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}