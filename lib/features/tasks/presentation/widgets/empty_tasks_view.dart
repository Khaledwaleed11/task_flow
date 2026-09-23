import 'package:flutter/material.dart';

class EmptyTasksView extends StatelessWidget {
  const EmptyTasksView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(
          alpha: 0.04,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withValues(
            alpha: 0.1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_rounded,
              size: 32,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Start adding tasks to track your project progress.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}