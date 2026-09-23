import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/task_repository.dart';

class ToggleTaskCompletion
    implements UseCase<Unit, ToggleTaskCompletionParams> {
  final TaskRepository repository;

  ToggleTaskCompletion(this.repository);

  @override
  Future<Either<Failure, Unit>> call(
      ToggleTaskCompletionParams params,
      ) {
    return repository.toggleTaskCompletion(
      projectId: params.projectId,
      taskId: params.taskId,
      isCompleted: params.isCompleted,
    );
  }
}

class ToggleTaskCompletionParams {
  final String projectId;
  final String taskId;
  final bool isCompleted;

  const ToggleTaskCompletionParams({
    required this.projectId,
    required this.taskId,
    required this.isCompleted,
  });
}