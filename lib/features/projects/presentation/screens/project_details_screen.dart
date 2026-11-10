import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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
        watchAssignedTasksUseCase: sl(),
        startTaskUseCase: sl(),
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
          backgroundColor: dialogColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          title: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: dialogColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: dialogColors.error,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  'Delete Task',
                  style: dialogTheme.textTheme.titleLarge?.copyWith(
                    color: dialogColors.onSurface,
                    fontWeight: FontWeight.w800,
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
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: dialogColors.primary),
              ),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: dialogColors.error,
                foregroundColor: dialogColors.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.deleteTask(
      projectId: project.id,
      taskId: task.id,
    );

    if (!context.mounted) return;

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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final totalTasks = provider.tasks.length;
        final completedTasks = provider.completedTasksCount;

        final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: colorScheme.surface,
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
                          onBack: () => Navigator.pop(context),
                        ),

                        const SizedBox(height: 24),

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

                        _ProjectTasksHeading(taskCount: totalTasks),

                        const SizedBox(height: 15),

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
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 13),
                              child: TaskCard(
                                task: task,
                                isActionLoading: false,
                                showActions: true,
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 5,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text(
              'Add Task',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
        );
      },
    );
  }
}

class _ProjectTasksHeading extends StatelessWidget {
  final int taskCount;

  const _ProjectTasksHeading({required this.taskCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.checklist_rounded,
            color: AppColors.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project Tasks',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Manage and track your project tasks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$taskCount Tasks',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
