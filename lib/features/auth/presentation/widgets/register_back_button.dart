import 'package:flutter/material.dart';

class RegisterBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onPressed,
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
          size: 21,
        ),
      ),
    );
  }
}