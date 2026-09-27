import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity?>> getUser(String userId);
}
