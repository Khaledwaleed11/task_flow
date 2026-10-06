import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class RegisterBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onPressed,
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
          size: 21,
        ),
      ),
    );
  }
}