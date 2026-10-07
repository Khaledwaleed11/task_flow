import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class RecentProjectsHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const RecentProjectsHeader({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Projects',
            style: AppTextStyles.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}