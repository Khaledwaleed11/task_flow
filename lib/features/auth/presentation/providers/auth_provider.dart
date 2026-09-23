import 'package:flutter/foundation.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
}

class AuthProvider extends ChangeNotifier {
  final Login loginUseCase;
  final Register registerUseCase;
  final Logout logoutUseCase;
  final GetCurrentUser getCurrentUserUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated;

  Future<void> checkCurrentUser() async {
    _setLoading();

    final result = await getCurrentUserUseCase(
      const NoParams(),
    );

    result.fold(
          (failure) {
        _setFailure(failure.message);
      },
          (user) {
        if (user == null) {
          _status = AuthStatus.unauthenticated;
        } else {
          _user = user;
          _status = AuthStatus.authenticated;
        }

        _clearError();
        notifyListeners();
      },
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await loginUseCase(
      LoginParams(
        email: email,
        password: password,
      ),
    );

    return result.fold(
          (failure) {
        _setFailure(failure.message);
        return false;
      },
          (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        _clearError();
        notifyListeners();

        return true;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();

    final result = await registerUseCase(
      RegisterParams(
        name: name,
        email: email,
        password: password,
      ),
    );

    return result.fold(
          (failure) {
        _setFailure(failure.message);
        return false;
      },
          (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        _clearError();
        notifyListeners();

        return true;
      },
    );
  }

  Future<bool> logout() async {
    _setLoading();

    final result = await logoutUseCase(
      const NoParams(),
    );

    return result.fold(
          (failure) {
        _setFailure(failure.message);
        return false;
      },
          (_) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        _clearError();
        notifyListeners();

        return true;
      },
    );
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _clearError();
    notifyListeners();
  }

  void _setFailure(String message) {
    _status = AuthStatus.failure;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}