import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'admin_progress_ring.dart';

class AdminWelcomeSection extends StatelessWidget {
  final int projectCount;
  final double completionRate;

  const AdminWelcomeSection({
    super.key,
    required this.projectCount,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final percentage = (completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: isDark ? 0.14 : 0.20,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.14,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'OVERVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Everything under control.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  projectCount == 0
                      ? 'Create your first project and start building your workspace.'
                      : '$projectCount active '
                      '${projectCount == 1 ? 'project' : 'projects'} '
                      'in your workspace.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.72,
                    ),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          AdminProgressRing(
            percentage: percentage,
          ),
        ],
      ),
    );
  }
}