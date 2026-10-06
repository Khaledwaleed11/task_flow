import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileImage
    implements UseCase<UserEntity, UpdateProfileImageParams> {
  final ProfileRepository repository;

  UpdateProfileImage(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      UpdateProfileImageParams params,
      ) {
    return repository.updateProfileImage(
      userId: params.userId,
      filePath: params.filePath,
    );
  }
}

class UpdateProfileImageParams {
  final String userId;
  final String filePath;

  const UpdateProfileImageParams({
    required this.userId,
    required this.filePath,
  });
}