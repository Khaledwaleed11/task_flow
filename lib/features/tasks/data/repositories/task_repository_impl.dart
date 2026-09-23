import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/task_exception.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/task_failure..dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  // =========================
  // Create Task
  // =========================

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskPriority priority,
  }) async {
    try {
      final task = await remoteDataSource.createTask(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority.name,
      );

      return Right(task.toEntity());
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to create task.'));
    }
  }

  // =========================
  // Get Tasks
  // =========================

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    required String projectId,
  }) async {
    try {
      final tasks = await remoteDataSource.getTasks(projectId: projectId);

      return Right(tasks.map((task) => task.toEntity()).toList());
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to get tasks.'));
    }
  }

  // =========================
  // Get Task By ID
  // =========================

  @override
  Future<Either<Failure, TaskEntity>> getTaskById({
    required String projectId,
    required String taskId,
  }) async {
    try {
      final task = await remoteDataSource.getTaskById(
        projectId: projectId,
        taskId: taskId,
      );

      if (task == null) {
        return const Left(TaskFailure('Task not found.'));
      }

      return Right(task.toEntity());
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to get task.'));
    }
  }

  // =========================
  // Update Task
  // =========================

  @override
  Future<Either<Failure, Unit>> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required bool isCompleted,
    required bool oldIsCompleted,
  }) async {
    try {
      await remoteDataSource.updateTask(
        projectId: projectId,
        taskId: taskId,
        title: title,
        description: description,
        priority: priority.name,
        isCompleted: isCompleted,
        oldIsCompleted: oldIsCompleted,
      );

      return const Right(unit);
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to update task.'));
    }
  }

  // =========================
  // Delete Task
  // =========================

  @override
  Future<Either<Failure, Unit>> deleteTask({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      await remoteDataSource.deleteTask(
        projectId: projectId,
        taskId: taskId,
        isCompleted: isCompleted,
      );

      return const Right(unit);
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to delete task.'));
    }
  }

  // =========================
  // Toggle Task Completion
  // =========================

  @override
  Future<Either<Failure, Unit>> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      await remoteDataSource.toggleTaskCompletion(
        projectId: projectId,
        taskId: taskId,
        isCompleted: isCompleted,
      );

      return const Right(unit);
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to update task status.'));
    }
  }
}
