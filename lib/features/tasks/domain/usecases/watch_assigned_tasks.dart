import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class WatchAssignedTasks {
  final TaskRepository repository;

  WatchAssignedTasks(this.repository);

  Stream<Either<Failure, List<TaskEntity>>> call(
    WatchAssignedTasksParams params,
  ) {
    return repository.watchAssignedTasks(userId: params.userId);
  }
}

class WatchAssignedTasksParams {
  final String userId;

  const WatchAssignedTasksParams({required this.userId});
}
