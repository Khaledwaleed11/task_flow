import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class GetProjectById
    implements UseCase<ProjectEntity, GetProjectByIdParams> {
  final ProjectRepository repository;

  GetProjectById(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(
      GetProjectByIdParams params,
      ) {
    return repository.getProjectById(
      params.projectId,
    );
  }
}

class GetProjectByIdParams {
  final String projectId;

  const GetProjectByIdParams({
    required this.projectId,
  });
}