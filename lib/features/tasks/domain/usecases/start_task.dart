
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/task_repository.dart';

class StartTask implements UseCase<Unit, StartTaskParams> {
  final TaskRepository repository;

  StartTask(this.repository);

  @override
  Future<Either<Failure, Unit>> call(StartTaskParams params) {
    return repository.startTask(
      projectId: params.projectId,
      taskId: params.taskId,
    );
  }
}

class StartTaskParams {
  final String projectId;
  final String taskId;

  const StartTaskParams({
    required this.projectId,
    required this.taskId,
  });
}
