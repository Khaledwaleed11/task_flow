import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/auth_exception.dart';
import '../../../../core/error/failures/auth_failure.dart';
import '../../../../core/error/failures/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity?>> getUser(String userId) async {
    try {
      final user = await remoteDataSource.getUser(userId);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (_) {
      return const Left(AuthFailure('Failed to get user.'));
    }
  }
}
