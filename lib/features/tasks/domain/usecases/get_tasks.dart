import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasks implements UseCase<List<TaskEntity>, GetTasksParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
      GetTasksParams params,
      ) {
    return repository.getTasks(
      projectId: params.projectId,
    );
  }
}

class GetTasksParams {
  final String projectId;

  const GetTasksParams({
    required this.projectId,
  });
}