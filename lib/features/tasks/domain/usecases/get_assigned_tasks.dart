import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetAssignedTasks
    implements UseCase<List<TaskEntity>, GetAssignedTasksParams> {
  final TaskRepository repository;

  GetAssignedTasks(this.repository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(
    GetAssignedTasksParams params,
  ) {
    return repository.getAssignedTasks(userId: params.userId);
  }
}

class GetAssignedTasksParams {
  final String userId;

  const GetAssignedTasksParams({required this.userId});
}
