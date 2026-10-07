import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'admin_role_badge.dart';
import 'admin_user_initial.dart';

class AdminUserCard extends StatelessWidget {
  final UserEntity user;

  const AdminUserCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isAdmin = user.role == UserRole.admin;

    final name = user.name.trim().isEmpty
        ? 'Unnamed User'
        : user.name.trim();

    final initial = name.isNotEmpty
        ? name[0].toUpperCase()
        : '?';

    final roleColor = isAdmin
        ? colorScheme.primary
        : AppColors.success;

    final imageUrl =
        user.profileImageUrl?.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colorScheme.outline.withValues(
              alpha: 0.6,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isAdmin
                    ? AppColors.primarySoft
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(17),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return AdminUserInitial(
                      initial: initial,
                      roleColor: roleColor,
                    );
                  },
                )
                    : AdminUserInitial(
                  initial: initial,
                  roleColor: roleColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AdminRoleBadge(
                        isAdmin: isAdmin,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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