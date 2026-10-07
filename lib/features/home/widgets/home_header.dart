import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback onLogout;

  const HomeHeader({
    super.key,
    required this.user,
    required this.onLogout,
  });

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'there';

    final imageUrl = user?.profileImageUrl;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back 👋',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Let's get things done.",
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              _openProfile(context);
            }

            if (value == 'logout') {
              onLogout();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          child: GestureDetector(
            onTap: () => _openProfile(context),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                    );
                  },
                )
                    : const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}