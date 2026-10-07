import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ProjectsHeader extends StatelessWidget {
  final int projectCount;

  const ProjectsHeader({
    super.key,
    required this.projectCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Projects',
                    style: AppTextStyles.headline.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Manage your projects and keep your tasks organized.',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_rounded,
                    size: 17,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    '$projectCount',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}