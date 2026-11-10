import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/home_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/create_project_screen.dart';
import '../../../projects/presentation/screens/project_details_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../projects/presentation/widgets/project_card.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../widgets/home_empty_projects.dart';
import '../../widgets/home_error_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();
    final taskProvider = context.read<TaskProvider>();

    Future.microtask(() {
      final user = authProvider.user;

      if (user == null) return;

      if (user.role == UserRole.admin) {
        projectProvider.getProjects();
      } else {
        taskProvider.getAssignedTasks(userId: user.id);
      }
    });
  }

  Future<void> _refresh() async {
    final user = context.read<AuthProvider>().user;

    if (user == null) return;

    if (user.role == UserRole.admin) {
      await context.read<ProjectProvider>().getProjects();
    } else {
      await context.read<TaskProvider>().getAssignedTasks(userId: user.id);
    }
  }

  Future<void> _openCreateProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );

    if (!mounted) return;

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _openProjects() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectsScreen()),
    );

    if (!mounted) return;

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _openProjectDetails(ProjectEntity project) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailsScreen(project: project)),
    );

    if (!mounted) return;

    await context.read<ProjectProvider>().getProjects();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer3<ProjectProvider, AuthProvider, TaskProvider>(
      builder: (context, projectProvider, authProvider, taskProvider, child) {
        final isAdmin = authProvider.user?.role == UserRole.admin;

        final projects = projectProvider.projects;
        final assignedTasks = taskProvider.tasks;

        final totalTasks = isAdmin
            ? projects.fold<int>(0, (sum, project) => sum + project.totalTasks)
            : assignedTasks.length;

        final completedTasks = isAdmin
            ? projects.fold<int>(
                0,
                (sum, project) => sum + project.completedTasks,
              )
            : assignedTasks.where((task) => task.isCompleted).length;

        final progress = totalTasks == 0
            ? 0.0
            : (completedTasks / totalTasks).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeHeader(user: authProvider.user),
                          const SizedBox(height: 26),

                          _WorkspaceDashboardCard(
                            isAdmin: isAdmin,
                            projectsCount: projects.length,
                            tasksCount: totalTasks,
                            completedTasksCount: completedTasks,
                            progress: progress,
                            isDark: isDark,
                          ),

                          const SizedBox(height: 30),

                          if (!isAdmin) ...[
                            _buildAssignedTasksSection(
                              taskProvider: taskProvider,
                              tasks: assignedTasks,
                            ),
                          ],

                          if (isAdmin) ...[
                            _buildAdminProjectsSection(
                              projectProvider: projectProvider,
                              projects: projects,
                            ),
                          ],
                        ],
                      ),
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


  Widget _buildAdminProjectsSection({
    required ProjectProvider projectProvider,
    required List<ProjectEntity> projects,
  }) {
    if (projectProvider.status == ProjectStatus.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 65),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (projectProvider.status == ProjectStatus.failure) {
      return HomeErrorView(
        message: projectProvider.errorMessage ?? 'Failed to load projects.',
        onRetry: projectProvider.getProjects,
      );
    }

    if (projects.isEmpty) {
      return HomeEmptyProjects(onCreateProject: _openCreateProject);
    }

    final recentProjects = projects.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Recent projects',
          subtitle: 'Keep track of your latest work',
          actionLabel: 'View all',
          onAction: _openProjects,
        ),
        const SizedBox(height: 16),

        ...recentProjects.map(
          (project) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ProjectCard(
              project: project,
              showActions: false,
              onTap: () => _openProjectDetails(project),
            ),
          ),
        ),

        const SizedBox(height: 4),

        _CreateProjectButton(onTap: _openCreateProject),
      ],
    );
  }

  Widget _buildAssignedTasksSection({
    required TaskProvider taskProvider,
    required List<TaskEntity> tasks,
  }) {
    if (taskProvider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (taskProvider.status == TaskStatus.failure) {
      return _MessageCard(
        icon: Icons.error_outline_rounded,
        title: 'Something went wrong',
        message: taskProvider.errorMessage ?? 'Failed to load assigned tasks.',
      );
    }

    if (tasks.isEmpty) {
      return const _MessageCard(
        icon: Icons.task_alt_rounded,
        title: 'No tasks assigned yet',
        message: 'Tasks assigned to you will appear here.',
      );
    }

    final visibleTasks = tasks.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'My tasks',
          subtitle: 'Your assigned work at a glance',
          actionLabel: '${tasks.length} tasks',
        ),
        const SizedBox(height: 16),

        ...visibleTasks.map((task) {
          final isActionLoading =
              taskProvider.actionTaskId == task.id &&
              taskProvider.actionStatus == TaskActionStatus.loading;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TaskCard(
              task: task,
              isActionLoading: isActionLoading,
              showActions: false,
              onStart: () async {
                final success = await taskProvider.startTask(
                  projectId: task.projectId,
                  taskId: task.id,
                );

                if (!success && context.mounted) {
                  final message = taskProvider.actionErrorMessage;

                  if (message != null && message.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              },
              onComplete: () async {
                final success = await taskProvider.toggleTaskCompletion(
                  projectId: task.projectId,
                  taskId: task.id,
                  isCompleted: task.isCompleted,
                  updateProjectStats: false,
                );

                if (!success && context.mounted) {
                  final message = taskProvider.actionErrorMessage;

                  if (message != null && message.isNotEmpty) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(message)));
                  }
                }
              },
            ),
          );
        }),

        if (tasks.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Center(
              child: Text(
                '+ ${tasks.length - 5} more tasks',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WorkspaceDashboardCard extends StatelessWidget {
  final bool isAdmin;
  final int projectsCount;
  final int tasksCount;
  final int completedTasksCount;
  final double progress;
  final bool isDark;

  const _WorkspaceDashboardCard({
    required this.isAdmin,
    required this.projectsCount,
    required this.tasksCount,
    required this.completedTasksCount,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pendingTasks = (tasksCount - completedTasksCount).clamp(
      0,
      tasksCount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'YOUR WORKSPACE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.warning,
                size: 23,
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            isAdmin ? 'Manage your work.' : 'Your work, your progress.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            isAdmin
                ? 'Everything your team is working on.'
                : 'Stay focused and keep moving forward.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              if (isAdmin) ...[
                Expanded(
                  child: _DashboardStat(
                    value: '$projectsCount',
                    label: 'Projects',
                  ),
                ),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: _DashboardStat(
                  value: '$tasksCount',
                  label: 'Total tasks',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _DashboardStat(
                  value: '$completedTasksCount',
                  label: 'Completed',
                  highlight: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall progress',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.warning,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            '$pendingTasks tasks remaining',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _DashboardStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: highlight ? 0.22 : 0.13),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CreateProjectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateProjectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkCard : AppColors.primarySoft,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Create new project',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 29),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
