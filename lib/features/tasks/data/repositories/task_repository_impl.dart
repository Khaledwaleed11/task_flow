import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/error/exceptions/task_exception.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/task_failure..dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    String? assignedUserId,
  }) async {
    try {
      final task = await remoteDataSource.createTask(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority.name,
        assignedUserId: assignedUserId,
      );

      return Right(task.toEntity());
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to create task.'));
    }
  }

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

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchTasks({
    required String projectId,
  }) async* {
    try {
      await for (final tasks in remoteDataSource.watchTasks(
        projectId: projectId,
      )) {
        yield Right(tasks.map((task) => task.toEntity()).toList());
      }
    } on TaskException catch (e) {
      yield Left(TaskFailure(e.message));
    } catch (_) {
      yield const Left(TaskFailure('Failed to watch tasks.'));
    }
  }

  @override
  Stream<Either<Failure, List<TaskEntity>>> watchAllTasks() async* {
    try {
      await for (final tasks in remoteDataSource.watchAllTasks()) {
        yield Right(tasks.map((task) => task.toEntity()).toList());
      }
    } on TaskException catch (e) {
      debugPrint('WATCH ALL TASKS TASK EXCEPTION: ${e.message}');
      yield Left(TaskFailure(e.message));
    } catch (e, stackTrace) {
      debugPrint('WATCH ALL TASKS REPOSITORY ERROR: $e');
      debugPrint('WATCH ALL TASKS REPOSITORY STACK: $stackTrace');
      yield Left(TaskFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TaskEntity>>> getAssignedTasks({
    required String userId,
  }) async {
    try {
      final tasks = await remoteDataSource.getAssignedTasks(userId: userId);
      return Right(tasks.map((task) => task.toEntity()).toList());
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to get assigned tasks.'));
    }
  }

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

  @override
  Future<Either<Failure, Unit>> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    String? assignedUserId,
  }) async {
    try {
      await remoteDataSource.updateTask(
        projectId: projectId,
        taskId: taskId,
        title: title,
        description: description,
        priority: priority.name,
        assignedUserId: assignedUserId,
      );

      return const Right(unit);
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to update task.'));
    }
  }

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

  @override
  Future<Either<Failure, Unit>> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
    required bool updateProjectStats,
  }) async {
    try {
      await remoteDataSource.toggleTaskCompletion(
        projectId: projectId,
        taskId: taskId,
        isCompleted: isCompleted,
        updateProjectStats: updateProjectStats,
      );

      return const Right(unit);
    } on TaskException catch (e) {
      return Left(TaskFailure(e.message));
    } catch (_) {
      return const Left(TaskFailure('Failed to update task status.'));
    }
  }
}
