import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/admin_user_provider.dart';
import 'admin_overview_metric.dart';

class AdminUsersOverview extends StatelessWidget {
  final AdminUserProvider provider;

  const AdminUsersOverview({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final adminCount = provider.users
        .where((user) => user.role == UserRole.admin)
        .length;

    final userCount = provider.users
        .where((user) => user.role == UserRole.user)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workspace members',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'A quick overview of your team',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AdminOverviewMetric(
                  value: '${provider.users.length}',
                  label: 'Total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminOverviewMetric(
                  value: '$userCount',
                  label: 'Users',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminOverviewMetric(
                  value: '$adminCount',
                  label: 'Admins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}