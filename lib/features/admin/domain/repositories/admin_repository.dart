import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers();
}
