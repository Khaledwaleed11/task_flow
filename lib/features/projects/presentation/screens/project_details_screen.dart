import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../admin/presentation/providers/admin_user_provider.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/screens/create_task_screen.dart';
import '../../../tasks/presentation/screens/edit_task_screen.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/project_details_hero.dart';
import '../widgets/project_details_top_bar.dart';
import '../widgets/project_info_card.dart';
import '../widgets/task_statistics_card.dart';
import '../widgets/tasks_error_view.dart';
import '../widgets/tasks_loading_state.dart';
import '../widgets/tasks_section_header.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectEntity project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(
        createTaskUseCase: sl(),
        getTasksUseCase: sl(),
        getAssignedTasksUseCase: sl(),
        updateTaskUseCase: sl(),
        deleteTaskUseCase: sl(),
        toggleTaskCompletionUseCase: sl(),
        watchTasksUseCase: sl(),
      )..watchTasks(projectId: project.id),
      child: _ProjectDetailsView(project: project),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  final ProjectEntity project;

  const _ProjectDetailsView({required this.project});

  Future<void> _openCreateTask(
    BuildContext context,
    TaskProvider provider,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider(create: (_) => sl<AdminUserProvider>()),
          ],
          child: CreateTaskScreen(projectId: project.id),
        ),
      ),
    );
  }

  Future<void> _openEditTask(
    BuildContext context,
    TaskProvider provider,
    dynamic task,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: provider),
            ChangeNotifierProvider(create: (_) => sl<AdminUserProvider>()),
          ],
          child: EditTaskScreen(projectId: project.id, task: task),
        ),
      ),
    );
  }

  Future<void> _deleteTask(
    BuildContext context,
    TaskProvider provider,
    dynamic task,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final dialogTheme = Theme.of(dialogContext);
        final dialogColors = dialogTheme.colorScheme;

        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: dialogColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: dialogColors.error,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Delete Task',
                  style: dialogTheme.textTheme.titleLarge?.copyWith(
                    color: dialogColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"? '
            'This action cannot be undone.',
            style: dialogTheme.textTheme.bodyMedium?.copyWith(
              color: dialogColors.onSurfaceVariant,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: dialogColors.primary),
              ),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: dialogColors.error,
                foregroundColor: dialogColors.onError,
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await provider.deleteTask(
      projectId: project.id,
      taskId: task.id,
    );

    if (!context.mounted) {
      return;
    }

    final snackBarColor = success ? colorScheme.tertiary : colorScheme.error;

    final snackBarIcon = success
        ? Icons.check_circle_outline_rounded
        : Icons.error_outline_rounded;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(snackBarIcon, color: colorScheme.onInverseSurface, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  success
                      ? 'Task deleted successfully'
                      : provider.actionErrorMessage ?? 'Failed to delete task',
                ),
              ),
            ],
          ),
          backgroundColor: snackBarColor,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final totalTasks = provider.tasks.length;
        final completedTasks = provider.completedTasksCount;

        final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () {
                return provider.getTasks(projectId: project.id);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        ProjectDetailsTopBar(
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 22),
                        ProjectDetailsHero(
                          project: project,
                          totalTasks: totalTasks,
                          completedTasks: completedTasks,
                          progress: progress,
                        ),
                        const SizedBox(height: 18),
                        ProjectInfoCard(project: project),
                        const SizedBox(height: 18),
                        TaskStatisticsCard(provider: provider),
                        const SizedBox(height: 30),
                        TasksSectionHeader(taskCount: totalTasks),
                        const SizedBox(height: 14),
                        if (provider.status == TaskStatus.loading)
                          const TasksLoadingState()
                        else if (provider.status == TaskStatus.failure)
                          TasksErrorView(
                            message:
                                provider.errorMessage ??
                                'Failed to load tasks.',
                            onRetry: () {
                              provider.watchTasks(projectId: project.id);
                            },
                          )
                        else if (!provider.hasTasks)
                          const EmptyTasksView()
                        else
                          ...provider.tasks.map((task) {
                            final isActionLoading =
                                provider.actionTaskId == task.id &&
                                provider.actionStatus ==
                                    TaskActionStatus.loading;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TaskCard(
                                task: task,
                                isActionLoading: isActionLoading,
                                onToggle: null,
                                onEdit: () {
                                  _openEditTask(context, provider, task);
                                },
                                onDelete: () {
                                  _deleteTask(context, provider, task);
                                },
                              ),
                            );
                          }),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isLoading
                ? null
                : () {
                    _openCreateTask(context, provider);
                  },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Add Task'),
          ),
        );
      },
    );
  }
}
