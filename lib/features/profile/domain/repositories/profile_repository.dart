import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> updateProfileImage({
    required String userId,
    required String filePath,
  });
}