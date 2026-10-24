import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../providers/task_provider.dart';
import '../providers/task_provider_factory.dart';
import '../widgets/task_card.dart';

class AdminTasksScreen extends StatelessWidget {
  const AdminTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskProvider>(
      create: (_) => createTaskProvider()..watchAllTasks(),
      child: const _AdminTasksView(),
    );
  }
}

class _AdminTasksView extends StatelessWidget {
  const _AdminTasksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Tasks')),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == TaskStatus.failure && provider.tasks.isEmpty) {
            return _AdminTasksMessage(
              message: provider.errorMessage ?? 'Failed to load tasks.',
              icon: Icons.error_outline_rounded,
              onRetry: provider.watchAllTasks,
              showRetry: true,
            );
          }

          if (provider.tasks.isEmpty) {
            return const _AdminTasksMessage(
              message: 'No tasks have been created yet.',
              icon: Icons.assignment_outlined,
            );
          }

          final tasks = provider.tasks;

          return RefreshIndicator(
            onRefresh: () async {
              provider.watchAllTasks();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return TaskCard(task: tasks[index], showActions: false);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminTasksMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool showRetry;

  const _AdminTasksMessage({
    required this.message,
    required this.icon,
    this.onRetry,
    this.showRetry = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (showRetry && onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
