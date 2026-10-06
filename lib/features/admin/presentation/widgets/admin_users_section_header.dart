import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AdminUsersSectionHeader extends StatelessWidget {
  const AdminUsersSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Members',
          style: AppTextStyles.headline,
        ),
        SizedBox(height: 4),
        Text(
          'People with access to your workspace',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}