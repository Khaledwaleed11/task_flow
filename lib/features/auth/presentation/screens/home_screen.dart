import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/create_project_screen.dart';
import '../../../projects/presentation/screens/project_details_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/home_empty_projects.dart';
import '../widgets/home_error_view.dart';
import '../widgets/home_header.dart';
import '../widgets/home_statistics_row.dart';
import '../widgets/recent_projects_header.dart';
import '../widgets/workspace_overview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      if (user == null) {
        return;
      }

      if (user.role == UserRole.admin) {
        context.read<ProjectProvider>().getProjects();
        return;
      }

      context.read<TaskProvider>().getAssignedTasks(userId: user.id);
    });
  }

  Future<void> _refresh() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return;
    }

    if (user.role == UserRole.admin) {
      await context.read<ProjectProvider>().getProjects();
      return;
    }

    await context.read<TaskProvider>().getAssignedTasks(userId: user.id);
  }

  Future<void> _openCreateProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );

    if (!mounted) {
      return;
    }

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _openProjects() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectsScreen()),
    );

    if (!mounted) {
      return;
    }

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _openProjectDetails(ProjectEntity project) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailsScreen(project: project)),
    );

    if (!mounted) {
      return;
    }

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProjectProvider, AuthProvider, TaskProvider>(
      builder: (context, projectProvider, authProvider, taskProvider, child) {
        final isAdmin = authProvider.user?.role == UserRole.admin;

        final projects = projectProvider.projects;
        final assignedTasks = taskProvider.tasks;

        final totalTasks = isAdmin
            ? projects.fold<int>(
          0,
              (sum, project) => sum + project.totalTasks,
        )
            : assignedTasks.length;

        final completedTasks = isAdmin
            ? projects.fold<int>(
          0,
              (sum, project) => sum + project.completedTasks,
        )
            : taskProvider.tasks.where((task) => task.isCompleted).length;

        final recentProjects = projects.take(3).toList();

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        HomeHeader(user: authProvider.user, onLogout: _logout),
                        const SizedBox(height: 24),
                        WorkspaceOverviewCard(projectCount: projects.length),
                        const SizedBox(height: 16),
                        HomeStatisticsRow(
                          projectsCount: projects.length,
                          tasksCount: totalTasks,
                          completedTasksCount: completedTasks,
                        ),
                        const SizedBox(height: 28),
                        if (!isAdmin)
                          _buildAssignedTasksSection(
                            taskProvider: taskProvider,
                            tasks: assignedTasks,
                          ),
                        if (!isAdmin) const SizedBox(height: 28),
                        if (isAdmin &&
                            projectProvider.status == ProjectStatus.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (isAdmin &&
                            projectProvider.status == ProjectStatus.failure)
                          HomeErrorView(
                            message:
                                projectProvider.errorMessage ??
                                'Failed to load projects.',
                            onRetry: projectProvider.getProjects,
                          )
                        else if (isAdmin && projects.isEmpty)
                          HomeEmptyProjects(onCreateProject: _openCreateProject)
                        else if (isAdmin) ...[
                          RecentProjectsHeader(onViewAll: _openProjects),
                          const SizedBox(height: 12),
                          ...recentProjects.map(
                            (project) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ProjectCard(
                                project: project,
                                showActions: false,
                                onTap: () {
                                  _openProjectDetails(project);
                                },
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildAssignedTasksSection({
    required TaskProvider taskProvider,
    required List<TaskEntity> tasks,
  }) {
    if (taskProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (taskProvider.status == TaskStatus.failure) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          taskProvider.errorMessage ?? 'Failed to load assigned tasks.',
        ),
      );
    }

    if (tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              'No assigned tasks',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Tasks assigned to you will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final visibleTasks = tasks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Assigned Tasks',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${tasks.length}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...visibleTasks.map((task) {
          final isActionLoading =
              taskProvider.actionTaskId == task.id &&
              taskProvider.actionStatus == TaskActionStatus.loading;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TaskCard(
              task: task,
              isActionLoading: isActionLoading,
              showActions: false,
              onToggle: () {
                taskProvider.toggleTaskCompletion(
                  projectId: task.projectId,
                  taskId: task.id,
                  isCompleted: task.isCompleted,
                  updateProjectStats: false,
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
