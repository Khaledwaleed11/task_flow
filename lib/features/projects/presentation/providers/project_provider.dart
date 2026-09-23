import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/usecases/create_project.dart';
import '../../domain/usecases/delete_project.dart';
import '../../domain/usecases/get_projects.dart';
import '../../domain/usecases/update_project.dart';

enum ProjectStatus {
  initial,
  loading,
  loaded,
  failure,
}

class ProjectProvider extends ChangeNotifier {
  final CreateProject createProjectUseCase;
  final GetProjects getProjectsUseCase;
  final UpdateProject updateProjectUseCase;
  final DeleteProject deleteProjectUseCase;

  ProjectProvider({
    required this.createProjectUseCase,
    required this.getProjectsUseCase,
    required this.updateProjectUseCase,
    required this.deleteProjectUseCase,
  });

  ProjectStatus _status = ProjectStatus.initial;

  List<ProjectEntity> _projects = [];

  String? _errorMessage;

  ProjectStatus get status => _status;

  List<ProjectEntity> get projects => List.unmodifiable(_projects);

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == ProjectStatus.loading;

  bool get hasProjects => _projects.isNotEmpty;

  Future<void> getProjects() async {
    _setLoading();

    final result = await getProjectsUseCase(const NoParams());

    result.fold(
          (failure) {
        _setFailure(failure.message);
      },
          (projects) {
        _projects = projects;

        _status = ProjectStatus.loaded;
        _clearError();
        notifyListeners();
      },
    );
  }

  Future<bool> createProject({
    required String name,
    required String description,
  }) async {
    _setLoading();

    final result = await createProjectUseCase(
      CreateProjectParams(
        name: name,
        description: description,
      ),
    );

    return result.fold(
          (failure) {
        _setFailure(failure.message);
        return false;
      },
          (project) {
        _projects = [
          project,
          ..._projects,
        ];

        _status = ProjectStatus.loaded;
        _clearError();
        notifyListeners();

        return true;
      },
    );
  }

  Future<bool> updateProject({
    required String projectId,
    required String name,
    required String description,
  }) async {
    _setLoading();

    final result = await updateProjectUseCase(
      UpdateProjectParams(
        projectId: projectId,
        name: name,
        description: description,
      ),
    );

    return result.fold(
          (failure) {
        _setFailure(failure.message);
        return false;
      },
          (_) {
        final index = _projects.indexWhere(
              (project) => project.id == projectId,
        );

        if (index != -1) {
          final oldProject = _projects[index];

          _projects[index] = ProjectEntity(
            id: oldProject.id,
            ownerId: oldProject.ownerId,
            name: name,
            description: description,
            createdAt: oldProject.createdAt,
            updatedAt: DateTime.now(),
            totalTasks: oldProject.totalTasks,
            completedTasks: oldProject.completedTasks,
          );
        }

        _status = ProjectStatus.loaded;
        _clearError();
        notifyListeners();

        return true;
      },
    );
  }

  Future<bool> deleteProject(String projectId) async {
    _setLoading();

    final result = await deleteProjectUseCase(
      DeleteProjectParams(
        projectId: projectId,
      ),
    );

    return result.fold(
          (failure) {
        _setFailure(failure.message);
        return false;
      },
          (_) {
        _projects.removeWhere(
              (project) => project.id == projectId,
        );

        _status = ProjectStatus.loaded;
        _clearError();
        notifyListeners();

        return true;
      },
    );
  }

  void _setLoading() {
    _status = ProjectStatus.loading;
    _clearError();
    notifyListeners();
  }

  void _setFailure(String message) {
    _status = ProjectStatus.failure;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}