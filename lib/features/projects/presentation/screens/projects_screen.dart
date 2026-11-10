import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
  final bool showBackButton;

  const ProjectsScreen({super.key, this.showBackButton = true});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      final projectProvider = context.read<ProjectProvider>();

      if (projectProvider.status == ProjectStatus.initial) {
        projectProvider.watchProjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final authProvider = context.read<AuthProvider>();

        final taskProvider = TaskProvider(
          createTaskUseCase: sl(),
          getTasksUseCase: sl(),
          getAssignedTasksUseCase: sl(),
          updateTaskUseCase: sl(),
          deleteTaskUseCase: sl(),
          toggleTaskCompletionUseCase: sl(),
          watchTasksUseCase: sl(),
          watchAllTasksUseCase: sl(),
          watchAssignedTasksUseCase: sl(),
          startTaskUseCase: sl(),
        );

        if (authProvider.isAdmin) {
          taskProvider.watchAllTasks();
        } else {
          final userId = authProvider.user?.id;

          if (userId != null && userId.isNotEmpty) {
            taskProvider.watchAssignedTasks(userId: userId);
          }
        }

        return taskProvider;
      },
      child: _ProjectsView(showBackButton: widget.showBackButton),
    );
  }
}

class _ProjectsView extends StatelessWidget {
  final bool showBackButton;

  const _ProjectsView({required this.showBackButton});

  void _openCreateProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Consumer2<ProjectProvider, TaskProvider>(
          builder: (context, projectProvider, taskProvider, child) {
            final allProjects = projectProvider.projects;
            final tasks = taskProvider.tasks;

            final assignedProjectIds = tasks
                .map((task) => task.projectId)
                .where((projectId) => projectId.isNotEmpty)
                .toSet();

            final projects = isAdmin
                ? allProjects
                : allProjects
                      .where(
                        (project) => assignedProjectIds.contains(project.id),
                      )
                      .toList();

            Future<void> refresh() async {
              await projectProvider.getProjects();

              if (!context.mounted) return;

              if (isAdmin) {
                taskProvider.watchAllTasks();
              } else {
                final userId = authProvider.user?.id;

                if (userId != null && userId.isNotEmpty) {
                  taskProvider.watchAssignedTasks(userId: userId);
                }
              }
            }

            final isLoading =
                projectProvider.status == ProjectStatus.loading ||
                taskProvider.status == TaskStatus.loading ||
                taskProvider.status == TaskStatus.initial;

            final hasError =
                projectProvider.status == ProjectStatus.failure ||
                taskProvider.status == TaskStatus.failure;

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: colorScheme.surface,
              onRefresh: refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: ProjectsTopBar(
                        projectCount: projects.length,
                        showBackButton: showBackButton,
                        showCreateButton: isAdmin,
                        onBack: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        onCreate: () {
                          if (!isAdmin) return;
                          _openCreateProject(context);
                        },
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: _ProjectsOverviewCard(
                        projectCount: projects.length,
                        taskCount: tasks.length,
                        isAdmin: isAdmin,
                      ),
                    ),
                  ),

                  if (isLoading)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  else if (hasError)
                    ProjectsErrorView(
                      message: projectProvider.status == ProjectStatus.failure
                          ? projectProvider.errorMessage ??
                                'Failed to load projects.'
                          : taskProvider.errorMessage ??
                                'Failed to load tasks.',
                      onRetry: () {
                        if (projectProvider.status == ProjectStatus.failure) {
                          projectProvider.watchProjects();
                        }

                        if (taskProvider.status == TaskStatus.failure) {
                          if (isAdmin) {
                            taskProvider.watchAllTasks();
                          } else {
                            final userId = authProvider.user?.id;

                            if (userId != null && userId.isNotEmpty) {
                              taskProvider.watchAssignedTasks(userId: userId);
                            }
                          }
                        }
                      },
                    )
                  else if (projects.isEmpty)
                    const ProjectsEmptyView()
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 10),
                      sliver: SliverToBoxAdapter(
                        child: _ProjectsSectionHeader(
                          isAdmin: isAdmin,
                          projectCount: projects.length,
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final project = projects[index];

                          if (!isAdmin) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: ProjectCard(
                                project: project,
                                showProjectDetails: false,
                                showActions: false,
                                isInteractive: false,
                                onTap: () {},
                              ),
                            );
                          }

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
                              showProjectDetails: true,
                              showActions: true,
                              isInteractive: true,
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
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openCreateProject(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 5,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'New Project',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            )
          : null,
    );
  }
}

class _ProjectsOverviewCard extends StatelessWidget {
  final int projectCount;
  final int taskCount;
  final bool isAdmin;

  const _ProjectsOverviewCard({
    required this.projectCount,
    required this.taskCount,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -35,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 65,
            bottom: -55,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.045),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isAdmin
                          ? Icons.dashboard_customize_rounded
                          : Icons.workspaces_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAdmin ? 'Workspace Overview' : 'My Workspace',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isAdmin
                              ? 'Keep your projects organized.'
                              : 'Your assigned project spaces.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: _OverviewMetric(
                      icon: Icons.folder_rounded,
                      value: '$projectCount',
                      label: 'Projects',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 43,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  Expanded(
                    child: _OverviewMetric(
                      icon: Icons.task_alt_rounded,
                      value: '$taskCount',
                      label: isAdmin ? 'Total Tasks' : 'My Tasks',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _OverviewMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 5),
        Icon(icon, color: AppColors.warning, size: 24),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectsSectionHeader extends StatelessWidget {
  final bool isAdmin;
  final int projectCount;

  const _ProjectsSectionHeader({
    required this.isAdmin,
    required this.projectCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? 'All Projects' : 'Assigned Projects',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAdmin
                    ? 'Manage your team workspaces'
                    : 'Projects connected to your tasks',
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
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$projectCount',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectsScreenActions {
  static Future<void> deleteProject(
    BuildContext context,
    ProjectProvider provider,
    ProjectEntity project,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;

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
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Delete Project',
                  style: dialogTheme.textTheme.titleMedium?.copyWith(
                    color: dialogColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${project.name}"? '
            'This action cannot be undone.',
            style: dialogTheme.textTheme.bodyMedium?.copyWith(
              color: dialogColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: dialogColors.onSurfaceVariant,
              ),
              child: const Text('Cancel'),
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

    final success = await provider.deleteProject(project.id);

    if (!context.mounted) return;

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
                color: colorScheme.onInverseSurface,
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
          backgroundColor: success ? colorScheme.primary : colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }
}
