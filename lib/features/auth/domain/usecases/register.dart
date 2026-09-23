import 'package:dartz/dartz.dart';

import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class Register implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  Register(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      RegisterParams params,
      ) {
    return repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
  });
}