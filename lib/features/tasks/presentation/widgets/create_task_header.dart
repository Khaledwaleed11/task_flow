import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class CreateTaskHeader extends StatelessWidget {
  final VoidCallback onBack;

  const CreateTaskHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            fixedSize: const Size(44, 44),
            side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.7)),
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        const SizedBox(width: 14),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.14 : 0.20,
                ),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            Icons.add_task_rounded,
            color: colorScheme.onPrimary,
            size: 27,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a new task',
                style: AppTextStyles.headline.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add a task to keep your project organized.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
