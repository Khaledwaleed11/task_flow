import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../providers/task_provider_factory.dart';
import '../widgets/task_card.dart';

class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => createTaskProvider(),
      child: const _MyTasksView(),
    );
  }
}

class _MyTasksView extends StatefulWidget {
  const _MyTasksView();

  @override
  State<_MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends State<_MyTasksView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final user = context.read<AuthProvider>().user;

      if (user != null) {
        context.read<TaskProvider>().getAssignedTasks(userId: user.id);
      }
    });
  }

  Future<void> _refresh() async {
    final user = context.read<AuthProvider>().user;

    if (user == null) return;

    await context.read<TaskProvider>().getAssignedTasks(userId: user.id);
  }

  Future<void> _toggleTask(TaskEntity task) async {
    final provider = context.read<TaskProvider>();

    final success = await provider.toggleTaskCompletion(
      projectId: task.projectId,
      taskId: task.id,
      isCompleted: task.isCompleted,
      updateProjectStats: false,
    );

    if (!mounted || success) return;

    final message = provider.actionErrorMessage;

    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks'), centerTitle: false),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.status == TaskStatus.failure && provider.tasks.isEmpty) {
            return _TasksMessage(
              message: provider.errorMessage ?? 'Failed to load tasks.',
              icon: Icons.error_outline_rounded,
              actionLabel: 'Try again',
              onAction: _refresh,
            );
          }

          if (provider.tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  _TasksMessage(
                    message: 'No tasks assigned to you yet.',
                    icon: Icons.task_alt_rounded,
                  ),
                ],
              ),
            );
          }

          final tasks = provider.tasks;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];

                final isActionLoading =
                    provider.actionTaskId == task.id &&
                    provider.actionStatus == TaskActionStatus.loading;

                return TaskCard(
                  task: task,
                  isActionLoading: isActionLoading,
                  showActions: false,
                  onToggle: () => _toggleTask(task),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TasksMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _TasksMessage({
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
