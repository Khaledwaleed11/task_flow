
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../auth/domain/entities/user_entity.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  final UserEntity? user;

  const HomeHeader({
    super.key,
    required this.user,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'there';

    final imageUrl = user?.profileImageUrl;

    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    final secondaryColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    'Good morning,',
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    name,
                    style: AppTextStyles.headline.copyWith(
                      color: textColor,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text('👋', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                "Let's get things done.",
                style: AppTextStyles.bodySecondary.copyWith(
                  color: secondaryColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.warning,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: isDark ? AppColors.darkCard : AppColors.surface,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildFallback(name),
                )
                    : _buildFallback(name),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(String name) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.primarySoft,
      child: name.isNotEmpty && name != 'there'
          ? Text(
        name[0].toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 23,
          fontWeight: FontWeight.w800,
        ),
      )
          : const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}
