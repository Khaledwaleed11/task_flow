import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project_entity.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';
import '../widgets/projects_empty_view.dart';
import '../widgets/projects_error_view.dart';
import '../widgets/projects_header.dart';
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
      final provider = context.read<ProjectProvider>();

      if (provider.status == ProjectStatus.initial) {
        provider.getProjects();
      }
    });
  }

  Future<void> _openCreateProject() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
    );
  }

  Future<void> _openEditProject(
      ProjectEntity project,
      ) async {
    debugPrint('OPEN EDIT PROJECT: ${project.id}');

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProjectScreen(
          project: project,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await context.read<ProjectProvider>().getProjects();
  }
  Future<void> _openProjectDetails(project) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailsScreen(project: project)),
    );

    if (!mounted) {
      return;
    }

    await context.read<ProjectProvider>().getProjects();
  }

  Future<void> _deleteProject(
      ProjectProvider provider,
      ProjectEntity project,
      ) async {
    debugPrint('DELETE PROJECT START: ${project.id}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text(
            'Are you sure you want to delete '
                '"${project.name}"?',
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    debugPrint('DELETE CONFIRMED: $confirmed');

    if (confirmed != true || !mounted) {
      return;
    }

    debugPrint('CALLING PROVIDER DELETE');

    final success = await provider.deleteProject(
      project.id,
    );

    debugPrint('DELETE RESULT: $success');

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Project deleted successfully'
                : provider.errorMessage ??
                'Failed to delete project',
          ),
          backgroundColor:
          success ? AppColors.success : AppColors.error,
        ),
      );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateProject,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project'),
      ),
      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              onRefresh: provider.getProjects,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  ProjectsHeader(projectCount: provider.projects.length),

                  if (provider.status == ProjectStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.status == ProjectStatus.failure)
                    ProjectsErrorView(
                      message:
                          provider.errorMessage ?? 'Failed to load projects.',
                      onRetry: provider.getProjects,
                    )
                  else if (!provider.hasProjects)
                    const ProjectsEmptyView()
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final project = provider.projects[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child:ProjectCard(
                              project: project,
                              onTap: () => _openProjectDetails(project),
                              onEdit: () {
                                debugPrint('PROJECT SCREEN EDIT CALLBACK');
                                debugPrint('PROJECT ID: ${project.id}');
                                debugPrint('PROJECT NAME: ${project.name}');

                                _openEditProject(project);
                              },
                              onDelete: () {
                                debugPrint('PROJECT SCREEN DELETE CALLBACK');
                                debugPrint('PROJECT ID: ${project.id}');
                                debugPrint('PROJECT NAME: ${project.name}');

                                _deleteProject(provider, project);
                              },                            ),
                          );
                        }, childCount: provider.projects.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
