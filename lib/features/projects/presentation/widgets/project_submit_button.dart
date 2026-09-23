import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class ProjectSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final String loadingLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  const ProjectSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.loadingLabel,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 200,
          ),
          child: isLoading
              ? const SizedBox(
            key: ValueKey('loading'),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor:
              AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          )
              : Icon(
            icon,
            key: const ValueKey('icon'),
          ),
        ),
        label: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 200,
          ),
          child: Text(
            isLoading ? loadingLabel : label,
            key: ValueKey(
              isLoading ? loadingLabel : label,
            ),
            style: AppTextStyles.button,
          ),
        ),
      ),
    );
  }
}