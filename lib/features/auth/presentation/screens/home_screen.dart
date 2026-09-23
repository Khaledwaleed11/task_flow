import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../projects/presentation/screens/create_project_screen.dart';
import '../../../projects/domain/entities/project_entity.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/project_details_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../projects/presentation/widgets/project_card.dart';
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
      final provider = context.read<ProjectProvider>();

      if (provider.status == ProjectStatus.initial) {
        provider.getProjects();
      }
    });
  }
  Future<void> _openCreateProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateProjectScreen(),
      ),
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
    final authProvider = context.read<AuthProvider>();

    await authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProjectProvider, AuthProvider>(
      builder: (context, projectProvider, authProvider, child) {
        final projects = projectProvider.projects;

        final totalTasks = projects.fold<int>(
          0,
          (sum, project) => sum + project.totalTasks,
        );
        debugPrint(
          'HOME PROJECTS: ${projects.map((p) => '${p.name}: ${p.totalTasks}').toList()}',
        );

        debugPrint('HOME TOTAL TASKS: $totalTasks');

        final completedTasks = projects.fold<int>(
          0,
          (sum, project) => sum + project.completedTasks,
        );

        final recentProjects = projects.take(3).toList();

        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: projectProvider.getProjects,
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

                        if (projectProvider.status == ProjectStatus.loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 80),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (projectProvider.status ==
                            ProjectStatus.failure)
                          HomeErrorView(
                            message:
                                projectProvider.errorMessage ??
                                'Failed to load projects.',
                            onRetry: projectProvider.getProjects,
                          )
                        else if (projects.isEmpty)
                            HomeEmptyProjects(
                              onCreateProject: _openCreateProject,
                            )
                        else ...[
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
}
