import 'package:dartz/dartz.dart';

import '../../../../core/auth/current_user_provider.dart';
import '../../../../core/error/exceptions/app_exception.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/project_failure.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final CurrentUserProvider currentUserProvider;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.currentUserProvider,
  });

  @override
  Future<Either<Failure, ProjectEntity>> createProject({
    required String name,
    required String description,
  }) async {
    try {
      final userId = _getCurrentUserId();

      final project = await remoteDataSource.createProject(
        ownerId: userId,
        name: name,
        description: description,
      );

      return Right(project.toEntity());
    } on AppException catch (e) {
      return Left(ProjectFailure(e.message));
    } on ProjectFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ProjectFailure('Failed to create project.'));
    }
  }

  @override
  Future<Either<Failure, List<ProjectEntity>>> getProjects() async {
    try {
      final userId = _getCurrentUserId();

      final projects = await remoteDataSource.getProjects(ownerId: userId);

      return Right(projects.map((project) => project.toEntity()).toList());
    } on AppException catch (e) {
      return Left(ProjectFailure(e.message));
    } on ProjectFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ProjectFailure('Failed to get projects.'));
    }
  }

  @override
  Stream<Either<Failure, List<ProjectEntity>>> watchProjects() async* {
    try {
      final userId = _getCurrentUserId();

      await for (final projects in remoteDataSource.watchProjects(
        ownerId: userId,
      )) {
        yield Right(projects.map((project) => project.toEntity()).toList());
      }
    } on AppException catch (e) {
      yield Left(ProjectFailure(e.message));
    } on ProjectFailure catch (e) {
      yield Left(e);
    } catch (e) {
      yield Left(ProjectFailure('Watch projects error: $e'));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> getProjectById(
    String projectId,
  ) async {
    try {
      final userId = _getCurrentUserId();

      final project = await remoteDataSource.getProjectById(
        ownerId: userId,
        projectId: projectId,
      );

      if (project == null) {
        return const Left(ProjectFailure('Project not found.'));
      }

      return Right(project.toEntity());
    } on AppException catch (e) {
      return Left(ProjectFailure(e.message));
    } on ProjectFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ProjectFailure('Failed to get project.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateProject({
    required String projectId,
    required String name,
    required String description,
  }) async {
    try {
      final userId = _getCurrentUserId();

      await remoteDataSource.updateProject(
        ownerId: userId,
        projectId: projectId,
        name: name,
        description: description,
      );

      return const Right(unit);
    } on AppException catch (e) {
      return Left(ProjectFailure(e.message));
    } on ProjectFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ProjectFailure('Failed to update project.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(String projectId) async {
    try {
      final userId = _getCurrentUserId();

      await remoteDataSource.deleteProject(
        ownerId: userId,
        projectId: projectId,
      );

      return const Right(unit);
    } on AppException catch (e) {
      return Left(ProjectFailure(e.message));
    } on ProjectFailure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ProjectFailure('Failed to delete project.'));
    }
  }

  String _getCurrentUserId() {
    final userId = currentUserProvider.currentUserId;

    if (userId == null || userId.isEmpty) {
      throw const ProjectFailure('User is not authenticated.');
    }

    return userId;
  }
}
