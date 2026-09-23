import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProjectsHeader extends StatelessWidget {
  final int projectCount;

  const ProjectsHeader({
    super.key,
    required this.projectCount,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your projects and keep your tasks organized.',
                    style: AppTextStyles.bodySecondary,
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
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder_rounded,
                    size: 17,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$projectCount',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
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