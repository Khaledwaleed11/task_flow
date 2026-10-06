import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProjectDetailsTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const ProjectDetailsTopBar({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: AppColors.textPrimary,
            fixedSize: const Size(44, 44),
            side: BorderSide(
              color: isDark
                  ? AppColors.darkSurface
                  : AppColors.border,
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Project Overview',
          style: AppTextStyles.title,
        ),
      ],
    );
  }
}