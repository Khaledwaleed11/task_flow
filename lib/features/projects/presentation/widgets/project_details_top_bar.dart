import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ProjectDetailsTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const ProjectDetailsTopBar({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            fixedSize: const Size(44, 44),
            side: BorderSide(
              color: colorScheme.outline.withValues(
                alpha: 0.7,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Text(
          'Project Overview',
          style: AppTextStyles.title.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}