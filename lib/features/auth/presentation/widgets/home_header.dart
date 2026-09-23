import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/user_entity.dart';

class HomeHeader extends StatelessWidget {
  final UserEntity? user;
  final VoidCallback onLogout;

  const HomeHeader({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'there';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back 👋',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 4),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headline.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.color,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Let's get things done.",
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              onLogout();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ];
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}