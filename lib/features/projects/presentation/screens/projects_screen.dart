import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/projects_empty_view.dart';
import '../widgets/projects_error_view.dart';
import '../widgets/projects_top_bar.dart';
import 'create_project_screen.dart';
import 'edit_project_screen.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      final provider = context.read<ProjectProvider>();

      if (provider.status == ProjectStatus.initial) {
        provider.watchProjects();
      }
    });
  }

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
        watchAllTasksUseCase: sl(),
      )..watchAllTasks(),
      child: const _ProjectsView(),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  const _ProjectsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<ProjectProvider, TaskProvider>(
          builder: (context, projectProvider, taskProvider, child) {
            final projects = projectProvider.projects;
            final tasks = taskProvider.tasks;

            return RefreshIndicator(
              onRefresh: () async {
                await projectProvider.getProjects();
                taskProvider.watchAllTasks();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: ProjectsTopBar(
                        projectCount: projects.length,
                        onBack: () {
                          Navigator.of(context).pop();
                        },
                        onCreate: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateProjectScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (projectProvider.status == ProjectStatus.loading ||
                      taskProvider.status == TaskStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (projectProvider.status == ProjectStatus.failure ||
                      taskProvider.status == TaskStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ProjectsErrorView(
                          message:
                              projectProvider.status == ProjectStatus.failure
                              ? projectProvider.errorMessage ??
                                    'Failed to load projects.'
                              : taskProvider.errorMessage ??
                                    'Failed to load tasks.',
                          onRetry: () {
                            if (projectProvider.status ==
                                ProjectStatus.failure) {
                              projectProvider.getProjects();
                            }

                            if (taskProvider.status == TaskStatus.failure) {
                              taskProvider.watchAllTasks();
                            }
                          },
                        ),
                      ),
                    )
                  else if (projects.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: ProjectsEmptyView(),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final project = projects[index];

                          final projectTasks = tasks.where(
                            (task) => task.projectId == project.id,
                          );

                          final totalTasks = projectTasks.length;

                          final completedTasks = projectTasks
                              .where((task) => task.isCompleted)
                              .length;

                          final pendingTasks = totalTasks - completedTasks;

                          final progress = totalTasks == 0
                              ? 0.0
                              : completedTasks / totalTasks;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ProjectCard(
                              project: project,
                              totalTasks: totalTasks,
                              completedTasks: completedTasks,
                              pendingTasks: pendingTasks,
                              progress: progress,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProjectDetailsScreen(project: project),
                                  ),
                                );
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProjectScreen(project: project),
                                  ),
                                );
                              },
                              onDelete: () {
                                _ProjectsScreenActions.deleteProject(
                                  context,
                                  projectProvider,
                                  project,
                                );
                              },
                            ),
                          );
                        }, childCount: projects.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project'),
      ),
    );
  }
}

class _ProjectsScreenActions {
  static Future<void> deleteProject(
    BuildContext context,
    ProjectProvider provider,
    ProjectEntity project,
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
                child: Text('Delete Project', style: AppTextStyles.title),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${project.name}"? '
            'This action cannot be undone.',
            style: AppTextStyles.bodySecondary,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 4, 24, 18),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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

    final success = await provider.deleteProject(project.id);

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
                      ? 'Project deleted successfully'
                      : provider.errorMessage ?? 'Failed to delete project',
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
  }
}
