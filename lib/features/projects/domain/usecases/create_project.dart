import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class CreateProject
    implements UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProject(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(
      CreateProjectParams params,
      ) {
    return repository.createProject(
      name: params.name,
      description: params.description,
    );
  }
}

class CreateProjectParams {
  final String name;
  final String description;

  const CreateProjectParams({
    required this.name,
    required this.description,
  });
}