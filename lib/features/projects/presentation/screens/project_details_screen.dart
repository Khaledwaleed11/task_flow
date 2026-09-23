import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/task_statistics_card.dart';
import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/screens/create_task_screen.dart';
import '../../../tasks/presentation/screens/edit_task_screen.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../widgets/empty_tasks_view.dart';
import '../widgets/project_details_header.dart';
import '../widgets/project_info_card.dart';
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
        updateTaskUseCase: sl(),
        deleteTaskUseCase: sl(),
        toggleTaskCompletionUseCase: sl(),
      )..getTasks(projectId: project.id),
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
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: CreateTaskScreen(
            projectId: project.id,
          ),
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
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
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
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete'),
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Task deleted successfully'
              : provider.actionErrorMessage ?? 'Failed to delete task',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Project Details')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: provider.isLoading
                ? null
                : () => _openCreateTask(context, provider),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Task'),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () {
                return provider.getTasks(projectId: project.id);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        ProjectDetailsHeader(
                          project: project,
                          totalTasks: provider.tasks.length,
                          completedTasks: provider.completedTasksCount,
                        ),

                        const SizedBox(height: 16),

                        ProjectInfoCard(
                          project: project,
                        ),

                        const SizedBox(height: 16),

                        TaskStatisticsCard(  provider: provider,),
                        const SizedBox(height: 28),

                        TasksSectionHeader(taskCount: provider.tasks.length),

                        const SizedBox(height: 12),

                        if (provider.status == TaskStatus.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (provider.status == TaskStatus.failure)
                          TasksErrorView(
                            message:
                                provider.errorMessage ??
                                'Failed to load tasks.',
                            onRetry: () {
                              provider.getTasks(projectId: project.id);
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
                                onToggle: () {
                                  provider.toggleTaskCompletion(
                                    projectId: project.id,
                                    taskId: task.id,
                                    isCompleted: task.isCompleted,
                                  );
                                },
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
        );
      },
    );
  }
}
