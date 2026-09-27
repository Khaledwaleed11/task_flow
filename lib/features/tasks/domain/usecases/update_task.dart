import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTask implements UseCase<Unit, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateTaskParams params) {
    return repository.updateTask(
      projectId: params.projectId,
      taskId: params.taskId,
      title: params.title,
      description: params.description,
      priority: params.priority,
      assignedUserId: params.assignedUserId,
    );
  }
}

class UpdateTaskParams {
  final String projectId;
  final String taskId;
  final String title;
  final String description;
  final TaskPriority priority;
  final String? assignedUserId;

  const UpdateTaskParams({
    required this.projectId,
    required this.taskId,
    required this.title,
    required this.description,
    required this.priority,
    this.assignedUserId,
  });
}
