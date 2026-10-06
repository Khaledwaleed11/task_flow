import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/create_project_screen.dart';
import '../../../projects/presentation/screens/edit_project_screen.dart';
import '../../../projects/presentation/screens/project_details_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/admin_user_provider.dart';
import '../widgets/admin_dashboard_header.dart';
import '../widgets/admin_empty_projects_state.dart';
import '../widgets/admin_error_state.dart';
import '../widgets/admin_loading_state.dart';
import '../widgets/admin_management_card.dart';
import '../widgets/admin_section_header.dart';
import '../widgets/admin_statistics_grid.dart';
import '../widgets/admin_welcome_section.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) {
        return;
      }

      context.read<ProjectProvider>().watchProjects();
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
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _openEditProject(
    BuildContext context,
    ProjectEntity project,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProjectScreen(project: project)),
    );

    if (!context.mounted) {
      return;
    }

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _deleteProject(
    BuildContext context,
    ProjectEntity project,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text(
            'Are you sure you want to delete "${project.name}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
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

    final projectProvider = context.read<ProjectProvider>();

    final success = await projectProvider.deleteProject(project.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Project deleted successfully'
                : projectProvider.errorMessage ?? 'Failed to delete project',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
  }

  Future<void> _openCreateProject(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );
  }

  Future<void> _openProjects(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectsScreen()),
    );
  }

  Future<void> _openProjectDetails(
    BuildContext context,
    ProjectEntity project,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailsScreen(project: project)),
    );
  }

  Future<void> _openUsers(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => sl<AdminUserProvider>(),
          child: const AdminUsersScreen(),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProjectProvider, TaskProvider>(
      builder: (context, projectProvider, taskProvider, child) {
        final projects = projectProvider.projects;
        final tasks = taskProvider.tasks;

        final totalTasks = tasks.length;

        final completedTasks = tasks.where((task) => task.isCompleted).length;

        final completionRate = totalTasks == 0
            ? 0.0
            : completedTasks / totalTasks;

        final recentProjects = projects.take(3).toList();

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AdminDashboardHeader(
                          user: context.read<AuthProvider>().user,
                          onLogout: () => _logout(context),
                        ),
                        const SizedBox(height: 28),
                        AdminWelcomeSection(
                          projectCount: projects.length,
                          completionRate: completionRate,
                        ),
                        const SizedBox(height: 24),
                        AdminStatisticsGrid(
                          projectsCount: projects.length,
                          tasksCount: totalTasks,
                          completedTasksCount: completedTasks,
                        ),
                        const SizedBox(height: 24),
                        AdminManagementCard(onTap: () => _openUsers(context)),
                        const SizedBox(height: 30),
                        AdminSectionHeader(
                          title: 'Recent Projects',
                          subtitle: 'Your latest workspace activity',
                          actionLabel: projects.isNotEmpty ? 'View All' : null,
                          onAction: projects.isNotEmpty
                              ? () => _openProjects(context)
                              : null,
                        ),
                        const SizedBox(height: 14),

                        if (projectProvider.status == ProjectStatus.loading ||
                            taskProvider.status == TaskStatus.loading)
                          const AdminLoadingState()
                        else if (projectProvider.status ==
                            ProjectStatus.failure)
                          AdminErrorState(
                            message:
                                projectProvider.errorMessage ??
                                'Failed to load projects.',
                            buttonLabel: 'Retry',
                            onRetry: () {
                              projectProvider.getProjects();
                            },
                          )
                        else if (taskProvider.status == TaskStatus.failure)
                          AdminErrorState(
                            message:
                                taskProvider.errorMessage ??
                                'Failed to load tasks.',
                            buttonLabel: 'Retry',
                            onRetry: taskProvider.watchAllTasks,
                          )
                        else if (projects.isEmpty)
                          AdminEmptyProjectsState(
                            onCreate: () => _openCreateProject(context),
                          )
                        else
                          ...recentProjects.map((project) {
                            final projectTasks = tasks.where(
                              (task) => task.projectId == project.id,
                            );

                            final projectTotalTasks = projectTasks.length;

                            final projectCompletedTasks = projectTasks
                                .where((task) => task.isCompleted)
                                .length;

                            final displayProject = ProjectEntity(
                              id: project.id,
                              ownerId: project.ownerId,
                              name: project.name,
                              description: project.description,
                              totalTasks: projectTotalTasks,
                              completedTasks: projectCompletedTasks,
                              createdAt: project.createdAt,
                              updatedAt: project.updatedAt,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: ProjectCard(
                                project: displayProject,
                                onTap: () {
                                  _openProjectDetails(context, project);
                                },
                                onEdit: () {
                                  _openEditProject(context, project);
                                },
                                onDelete: () {
                                  _deleteProject(context, project);
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
            onPressed: projectProvider.isLoading
                ? null
                : () => _openCreateProject(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Project'),
          ),
        );
      },
    );
  }
}
