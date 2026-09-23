import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RecentProjectsHeader extends StatelessWidget {
  final VoidCallback onViewAll;

  const RecentProjectsHeader({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Projects',
            style: AppTextStyles.title.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.color,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('View All'),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 17,
              ),
            ],
          ),
        ),
      ],
    );
  }
}