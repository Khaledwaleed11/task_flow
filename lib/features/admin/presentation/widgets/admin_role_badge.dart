import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AdminRoleBadge extends StatelessWidget {
  final bool isAdmin;

  const AdminRoleBadge({
    super.key,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAdmin
        ? AppColors.primary
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(
            alpha: 0.16,
          ),
        ),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}