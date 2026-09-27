import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, TaskEntity>> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    String? assignedUserId,
  });

  Future<Either<Failure, List<TaskEntity>>> getTasks({
    required String projectId,
  });

  Stream<Either<Failure, List<TaskEntity>>> watchTasks({
    required String projectId,
  });

  Stream<Either<Failure, List<TaskEntity>>> watchAllTasks();

  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks({
    required String userId,
  });

  Future<Either<Failure, TaskEntity>> getTaskById({
    required String projectId,
    required String taskId,
  });

  Future<Either<Failure, Unit>> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    String? assignedUserId,
  });

  Future<Either<Failure, Unit>> deleteTask({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  });

  Future<Either<Failure, Unit>> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
    required bool updateProjectStats,
  });
}
