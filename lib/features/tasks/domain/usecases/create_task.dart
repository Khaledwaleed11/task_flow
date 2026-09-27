import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTask implements UseCase<TaskEntity, CreateTaskParams> {
  final TaskRepository repository;

  CreateTask(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) {
    return repository.createTask(
      projectId: params.projectId,
      title: params.title,
      description: params.description,
      priority: params.priority,
      assignedUserId: params.assignedUserId,
    );
  }
}

class CreateTaskParams {
  final String projectId;
  final String title;
  final String description;
  final TaskPriority priority;
  final String? assignedUserId;

  const CreateTaskParams({
    required this.projectId,
    required this.title,
    required this.description,
    required this.priority,
    this.assignedUserId,
  });
}
