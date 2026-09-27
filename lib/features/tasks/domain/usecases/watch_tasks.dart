import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class WatchTasks {
  final TaskRepository repository;

  WatchTasks(this.repository);

  Stream<Either<Failure, List<TaskEntity>>> call(WatchTasksParams params) {
    return repository.watchTasks(projectId: params.projectId);
  }
}

class WatchTasksParams {
  final String projectId;

  const WatchTasksParams({required this.projectId});
}
