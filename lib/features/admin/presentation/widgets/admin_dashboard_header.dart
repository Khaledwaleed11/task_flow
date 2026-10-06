import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class AdminDashboardHeader extends StatelessWidget {
  final dynamic user;
  final VoidCallback onLogout;

  const AdminDashboardHeader({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = user?.name?.toString().trim() ?? '';
    final email = user?.email?.toString().trim() ?? '';
    final imageUrl = user?.profileImageUrl?.toString().trim() ?? '';

    final displayName = name.isNotEmpty ? name : 'Admin';

    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'A';

    return Row(
      children: [
        GestureDetector(
          onTap: () => _openProfile(context),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return _buildInitial(initial);
                },
              )
                  : _buildInitial(initial),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Workspace',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                ),
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _openProfile(context),
          tooltip: 'Profile',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: AppColors.textSecondary,
            fixedSize: const Size(46, 46),
            side: BorderSide(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.border,
            ),
          ),
          icon: const Icon(
            Icons.person_outline_rounded,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),

      ],
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}