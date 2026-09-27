import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/auth_exception.dart';
import '../../../../core/error/failures/auth_failure.dart';
import '../../../../core/error/failures/failure.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.userRemoteDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final firebaseUser =
      await authRemoteDataSource.register(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        name: name,
        role: UserRole.user,
      );

      await userRemoteDataSource.createUser(user);

      return Right(user);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(e.message),
      );
    } catch (_) {
      return const Left(
        AuthFailure(
          'Registration failed. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final firebaseUser =
      await authRemoteDataSource.login(
        email: email,
        password: password,
      );

      final user =
      await userRemoteDataSource.getUser(
        firebaseUser.uid,
      );

      if (user == null) {
        return const Left(
          AuthFailure(
            'User profile was not found.',
          ),
        );
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(e.message),
      );
    } catch (_) {
      return const Left(
        AuthFailure(
          'Login failed. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final firebaseUser =
      authRemoteDataSource.getCurrentUser();

      if (firebaseUser == null) {
        return const Right(null);
      }

      final user =
      await userRemoteDataSource.getUser(
        firebaseUser.uid,
      );

      return Right(user);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(e.message),
      );
    } catch (_) {
      return const Left(
        AuthFailure(
          'Failed to get current user.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await authRemoteDataSource.logout();

      return const Right(unit);
    } on AuthException catch (e) {
      return Left(
        AuthFailure(e.message),
      );
    } catch (_) {
      return const Left(
        AuthFailure(
          'Logout failed. Please try again.',
        ),
      );
    }
  }
}