import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminUsersTopBar extends StatelessWidget {
  final int userCount;
  final VoidCallback onBack;

  const AdminUsersTopBar({
    super.key,
    required this.userCount,
    required this.onBack,
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
                    alpha: 0.6,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
              ),
            ),
            const Spacer(),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.people_alt_outlined,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Users',
          style: AppTextStyles.display.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: Text(
                userCount == 0
                    ? 'Manage your workspace members'
                    : '$userCount '
                    '${userCount == 1 ? 'member' : 'members'} '
                    'in your workspace',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (userCount > 0) ...[
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