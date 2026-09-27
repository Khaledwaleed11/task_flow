import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../admin/presentation/providers/admin_user_provider.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/screens/create_task_screen.dart';
import '../../../tasks/presentation/screens/edit_task_screen.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/project_info_card.dart';
import '../widgets/task_statistics_card.dart';
import '../widgets/tasks_error_view.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Delete Task', style: AppTextStyles.title),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${task.title}"? '
            'This action cannot be undone.',
            style: AppTextStyles.bodySecondary,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
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
          backgroundColor: success ? AppColors.success : AppColors.error,
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
                        _DetailsTopBar(
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const SizedBox(height: 22),
                        _ProjectHero(
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
                          const _TasksLoadingState()
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
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Add Task'),
          ),
        );
      },
    );
  }
}

class _DetailsTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _DetailsTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: AppColors.textPrimary,
            fixedSize: const Size(44, 44),
            side: BorderSide(
              color: isDark ? AppColors.darkSurface : AppColors.border,
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        const SizedBox(width: 12),
        const Text('Project Overview', style: AppTextStyles.title),
      ],
    );
  }
}

class _ProjectHero extends StatelessWidget {
  final ProjectEntity project;
  final int totalTasks;
  final int completedTasks;
  final double progress;

  const _ProjectHero({
    required this.project,
    required this.totalTasks,
    required this.completedTasks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  '$percentage% complete',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            project.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.15,
            ),
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '$completedTasks of $totalTasks tasks completed',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksLoadingState extends StatelessWidget {
  const _TasksLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}
