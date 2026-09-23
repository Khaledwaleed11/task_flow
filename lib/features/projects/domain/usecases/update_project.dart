import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/project_repository.dart';

class UpdateProject
    implements UseCase<Unit, UpdateProjectParams> {
  final ProjectRepository repository;

  UpdateProject(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
      UpdateProjectParams params,
      ) {
    return repository.updateProject(
      projectId: params.projectId,
      name: params.name,
      description: params.description,
    );
  }
}

class UpdateProjectParams {
  final String projectId;
  final String name;
  final String description;

  const UpdateProjectParams({
    required this.projectId,
    required this.name,
    required this.description,
  });
}