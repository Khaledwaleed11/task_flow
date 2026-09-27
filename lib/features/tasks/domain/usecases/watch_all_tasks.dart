import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class WatchAllTasks {
  final TaskRepository repository;

  WatchAllTasks(this.repository);

  Stream<Either<Failure, List<TaskEntity>>> call() {
    return repository.watchAllTasks();
  }
}
