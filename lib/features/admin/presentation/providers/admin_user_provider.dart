import 'package:flutter/foundation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_users.dart';

enum AdminUserStatus { initial, loading, loaded, failure }

class AdminUserProvider extends ChangeNotifier {
  final GetUsers getUsersUseCase;

  AdminUserProvider({required this.getUsersUseCase});

  AdminUserStatus _status = AdminUserStatus.initial;

  List<UserEntity> _users = [];

  String? _errorMessage;

  AdminUserStatus get status => _status;

  List<UserEntity> get users => List.unmodifiable(_users);

  List<UserEntity> get assignableUsers => _users
      .where((user) => user.role == UserRole.user)
      .toList(growable: false);

  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AdminUserStatus.loading;

  bool get hasUsers => _users.isNotEmpty;

  bool get hasAssignableUsers => assignableUsers.isNotEmpty;

  Future<void> getUsers() async {
    _status = AdminUserStatus.loading;
    _errorMessage = null;

    notifyListeners();

    final result = await getUsersUseCase(NoParams());

    result.fold(
      (failure) {
        _status = AdminUserStatus.failure;
        _errorMessage = failure.message;

        notifyListeners();
      },
      (users) {
        _users = users;
        _status = AdminUserStatus.loaded;
        _errorMessage = null;

        notifyListeners();
      },
    );
  }
}
