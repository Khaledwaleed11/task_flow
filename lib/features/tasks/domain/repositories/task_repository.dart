import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  // =========================
  // Create Task
  // =========================

  Future<Either<Failure, TaskEntity>> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskPriority priority,
  });

  // =========================
  // Get Tasks
  // =========================

  Future<Either<Failure, List<TaskEntity>>> getTasks({
    required String projectId,
  });

  // =========================
  // Get Task By ID
  // =========================

  Future<Either<Failure, TaskEntity>> getTaskById({
    required String projectId,
    required String taskId,
  });

  // =========================
  // Update Task
  // =========================

  Future<Either<Failure, Unit>> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required bool isCompleted,

    // The previous completion state.
    // Used to update the project's completedTasks counter.
    required bool oldIsCompleted,
  });

  // =========================
  // Delete Task
  // =========================

  Future<Either<Failure, Unit>> deleteTask({
    required String projectId,
    required String taskId,

    // Needed to know whether completedTasks
    // should also be decremented.
    required bool isCompleted,
  });

  // =========================
  // Toggle Completion
  // =========================

  Future<Either<Failure, Unit>> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  });
}
