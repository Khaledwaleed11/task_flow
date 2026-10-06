import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/auth_exception.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/auth_failure.dart';
import '../../../auth/data/datasources/user_remote_data_source.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/image_storage_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final UserRemoteDataSource userRemoteDataSource;
  final ImageStorageDataSource imageStorageDataSource;

  ProfileRepositoryImpl({
    required this.userRemoteDataSource,
    required this.imageStorageDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> updateProfileImage({
    required String userId,
    required String filePath,
  }) async {
    try {
      final imageUrl = await imageStorageDataSource.uploadImage(
        userId: userId,
        filePath: filePath,
      );

      await userRemoteDataSource.updateProfileImage(
        userId: userId,
        imageUrl: imageUrl,
      );

      final updatedUser = await userRemoteDataSource.getUser(userId);

      if (updatedUser == null) {
        return const Left(
          AuthFailure('User profile was not found.'),
        );
      }

      return Right(updatedUser);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(
        AuthFailure('Failed to update profile image.'),
      );
    }
  }
}