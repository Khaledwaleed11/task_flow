import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTaskById
    implements UseCase<TaskEntity, GetTaskByIdParams> {
  final TaskRepository repository;

  GetTaskById(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(
      GetTaskByIdParams params,
      ) {
    return repository.getTaskById(
      projectId: params.projectId,
      taskId: params.taskId,
    );
  }
}

class GetTaskByIdParams {
  final String projectId;
  final String taskId;

  const GetTaskByIdParams({
    required this.projectId,
    required this.taskId,
  });
}