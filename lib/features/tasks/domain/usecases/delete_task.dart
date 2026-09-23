import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/task_repository.dart';

class DeleteTask implements UseCase<Unit, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteTaskParams params) {
    return repository.deleteTask(
      projectId: params.projectId,
      taskId: params.taskId,
      isCompleted: params.isCompleted,
    );
  }
}

class DeleteTaskParams {
  final String projectId;
  final String taskId;
  final bool isCompleted;

  const DeleteTaskParams({
    required this.projectId,
    required this.taskId,
    required this.isCompleted,
  });
}
