import 'package:flutter/material.dart';

class AdminUsersLoadingState extends StatelessWidget {
  const AdminUsersLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withValues(
            alpha: 0.6,
          ),
        ),
      ),
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}