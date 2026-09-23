import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Future<Either<Failure, ProjectEntity>> createProject({
    required String name,
    required String description,
  });

  Future<Either<Failure, List<ProjectEntity>>> getProjects();

  Future<Either<Failure, ProjectEntity>> getProjectById(
      String projectId,
      );

  Future<Either<Failure, Unit>> updateProject({
    required String projectId,
    required String name,
    required String description,
  });

  Future<Either<Failure, Unit>> deleteProject(
      String projectId,
      );
}