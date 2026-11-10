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
      if (!mounted) return;
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
        watchAssignedTasksUseCase: sl(),
        startTaskUseCase: sl(),
      )..watchAllTasks(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _background(BuildContext context) =>
      _isDark(context) ? AppColors.darkBackground : AppColors.background;

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

    if (!context.mounted) return;

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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final projectProvider = context.read<ProjectProvider>();
    final success = await projectProvider.deleteProject(project.id);

    if (!context.mounted) return;

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
          backgroundColor: _background(context),
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _refresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
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

                        _buildDashboardHero(
                          context,
                          projectsCount: projects.length,
                          completionRate: completionRate,
                          totalTasks: totalTasks,
                          completedTasks: completedTasks,
                        ),

                        const SizedBox(height: 25),

                        _buildSectionTitle(
                          context,
                          title: 'Overview',
                          subtitle: 'Your workspace at a glance',
                          icon: Icons.analytics_rounded,
                        ),

                        const SizedBox(height: 14),

                        AdminStatisticsGrid(
                          projectsCount: projects.length,
                          tasksCount: totalTasks,
                          completedTasksCount: completedTasks,
                        ),

                        const SizedBox(height: 24),

                        _buildSectionTitle(
                          context,
                          title: 'Workspace management',
                          subtitle: 'Manage your team and members',
                          icon: Icons.groups_rounded,
                        ),

                        const SizedBox(height: 14),

                        AdminManagementCard(onTap: () => _openUsers(context)),

                        const SizedBox(height: 28),

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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 5,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'New Project',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardHero(
    BuildContext context, {
    required int projectsCount,
    required int totalTasks,
    required int completedTasks,
    required double completionRate,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -25,
            child: Icon(
              Icons.dashboard_customize_rounded,
              size: 125,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 7),
                        Text(
                          'ADMIN OVERVIEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Your workspace,\none clear view.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                'Keep track of projects and team progress.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Overall task completion',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${(completionRate * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.warning,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        _heroMetric(
                          icon: Icons.folder_copy_rounded,
                          label: 'Projects',
                          value: projectsCount.toString(),
                        ),
                        const SizedBox(width: 18),
                        _heroMetric(
                          icon: Icons.task_alt_rounded,
                          label: 'Completed',
                          value: completedTasks.toString(),
                        ),
                        const SizedBox(width: 18),
                        _heroMetric(
                          icon: Icons.pending_actions_rounded,
                          label: 'Remaining',
                          value: (totalTasks - completedTasks).toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.warning),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final dark = _isDark(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: dark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: dark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
