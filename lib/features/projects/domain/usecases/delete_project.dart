import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/project_repository.dart';

class DeleteProject
    implements UseCase<Unit, DeleteProjectParams> {
  final ProjectRepository repository;

  DeleteProject(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
      DeleteProjectParams params,
      ) {
    return repository.deleteProject(
      params.projectId,
    );
  }
}

class DeleteProjectParams {
  final String projectId;

  const DeleteProjectParams({
    required this.projectId,
  });
}