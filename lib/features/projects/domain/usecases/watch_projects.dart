import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

class WatchProjects {
  final ProjectRepository repository;

  WatchProjects(this.repository);

  Stream<Either<Failure, List<ProjectEntity>>> call() {
    return repository.watchProjects();
  }
}
