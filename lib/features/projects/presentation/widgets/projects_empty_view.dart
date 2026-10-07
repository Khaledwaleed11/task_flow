import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ProjectsEmptyView extends StatelessWidget {
  const ProjectsEmptyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 38,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No projects yet',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Create your first project and start organizing your tasks.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}