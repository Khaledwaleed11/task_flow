import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/admin_exception.dart';
import '../../../../core/error/failures/admin_failure.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();

      return Right(users);
    } on AdminException catch (e) {
      return Left(AdminFailure(e.message));
    } catch (_) {
      return const Left(AdminFailure('Failed to get users.'));
    }
  }
}
