import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class AuthSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final String loadingLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.loadingLabel,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(
            alpha: 0.55,
          ),
          disabledForegroundColor: colorScheme.onPrimary.withValues(
            alpha: 0.75,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
            key: const ValueKey('loading'),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: colorScheme.onPrimary,
            ),
          )
              : Icon(
            icon,
            key: const ValueKey('icon'),
            size: 20,
          ),
        ),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isLoading ? loadingLabel : label,
            key: ValueKey(
              isLoading ? loadingLabel : label,
            ),
            style: AppTextStyles.button.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}