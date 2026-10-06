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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Users',
          style: AppTextStyles.display,
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              userCount == 0
                  ? 'Manage your workspace members'
                  : '$userCount '
                  '${userCount == 1 ? 'member' : 'members'} '
                  'in your workspace',
              style: AppTextStyles.bodySecondary,
            ),
            if (userCount > 0) ...[
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