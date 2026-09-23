import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions/auth_exception.dart';

abstract class AuthRemoteDataSource {
  Future<User> register({
    required String email,
    required String password,
  });

  Future<User> login({
    required String email,
    required String password,
  });

  User? getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
  });

  @override
  Future<User> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          'User registration failed.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Something went wrong. Please try again.',
      );
    }
  }

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          'Login failed.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException(
        'Something went wrong. Please try again.',
      );
    }
  }

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (_) {
      throw const AuthException(
        'Logout failed. Please try again.',
      );
    }
  }

  String _mapFirebaseAuthError(
      FirebaseAuthException exception,
      ) {
    switch (exception.code) {
      case 'invalid-email':
        return 'The email address is not valid.';

      case 'user-not-found':
        return 'No user found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'email-already-in-use':
        return 'This email is already registered.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      default:
        return 'Authentication failed. Please try again.';
    }
  }
}