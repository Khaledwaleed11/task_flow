import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions/auth_exception.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<void> createUser(UserModel user);

  Future<UserModel?> getUser(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to create user profile.');
    } catch (_) {
      throw const AuthException('Failed to create user profile.');
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final document = await _usersCollection.doc(userId).get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      return UserModel.fromJson(document.data()!);
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to get user profile.');
    } catch (_) {
      throw const AuthException('Failed to get user profile.');
    }
  }
}
