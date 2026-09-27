import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
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
                        _DashboardHeader(
                          user: context.read<AuthProvider>().user,
                          onLogout: () => _logout(context),
                        ),
                        const SizedBox(height: 28),
                        _WelcomeSection(
                          projectCount: projects.length,
                          completionRate: completionRate,
                        ),
                        const SizedBox(height: 24),
                        _StatisticsGrid(
                          projectsCount: projects.length,
                          tasksCount: totalTasks,
                          completedTasksCount: completedTasks,
                        ),
                        const SizedBox(height: 24),
                        _ManagementCard(onTap: () => _openUsers(context)),
                        const SizedBox(height: 30),
                        _SectionHeader(
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
                          const _LoadingState()
                        else if (projectProvider.status ==
                            ProjectStatus.failure)
                          _ErrorState(
                            message:
                                projectProvider.errorMessage ??
                                'Failed to load projects.',
                            buttonLabel: 'Retry',
                            onRetry: () {
                              projectProvider.getProjects();
                            },
                          )
                        else if (taskProvider.status == TaskStatus.failure)
                          _ErrorState(
                            message:
                                taskProvider.errorMessage ??
                                'Failed to load tasks.',
                            buttonLabel: 'Retry',
                            onRetry: taskProvider.watchAllTasks,
                          )
                        else if (projects.isEmpty)
                          _EmptyProjectsState(
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

class _DashboardHeader extends StatelessWidget {
  final dynamic user;
  final VoidCallback onLogout;

  const _DashboardHeader({required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = user?.name?.toString().trim() ?? '';
    final email = user?.email?.toString().trim() ?? '';

    final displayName = name.isNotEmpty ? name : 'Admin';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Workspace',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
              if (email.isNotEmpty)
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onLogout,
          tooltip: 'Logout',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: AppColors.textSecondary,
            fixedSize: const Size(46, 46),
            side: BorderSide(
              color: isDark ? AppColors.darkSurface : AppColors.border,
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
        ),
      ],
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final int projectCount;
  final double completionRate;

  const _WelcomeSection({
    required this.projectCount,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'OVERVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Everything under control.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  projectCount == 0
                      ? 'Create your first project and start building your workspace.'
                      : '$projectCount active ${projectCount == 1 ? 'project' : 'projects'} in your workspace.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          _ProgressRing(percentage: percentage),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percentage;

  const _ProgressRing({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'done',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  final int projectsCount;
  final int tasksCount;
  final int completedTasksCount;

  const _StatisticsGrid({
    required this.projectsCount,
    required this.tasksCount,
    required this.completedTasksCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.folder_copy_outlined,
            value: '$projectsCount',
            label: 'Projects',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.checklist_rounded,
            value: '$tasksCount',
            label: 'Tasks',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.task_alt_rounded,
            value: '$completedTasksCount',
            label: 'Completed',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkSurface : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value, style: AppTextStyles.headline.copyWith(fontSize: 23)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ManagementCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.darkSurface : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  color: AppColors.primaryDark,
                  size: 25,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Users', style: AppTextStyles.title),
                    SizedBox(height: 4),
                    Text(
                      'View registered users and manage access.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headline.copyWith(fontSize: 21)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 70),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.buttonLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text('Something went wrong', style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 130,
            child: FilledButton(onPressed: onRetry, child: Text(buttonLabel)),
          ),
        ],
      ),
    );
  }
}

class _EmptyProjectsState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyProjectsState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text('No projects yet', style: AppTextStyles.title),
          const SizedBox(height: 7),
          const Text(
            'Create your first project and start organizing your work.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 190,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Project'),
            ),
          ),
        ],
      ),
    );
  }
}
