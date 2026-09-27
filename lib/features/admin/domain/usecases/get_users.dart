import 'package:dartz/dartz.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class GetUsers implements UseCase<List<UserEntity>, NoParams> {
final AdminRepository repository;

GetUsers(this.repository);

@override
Future<Either<Failure, List<UserEntity>>> call(NoParams params) {
return repository.getUsers();
}
}
