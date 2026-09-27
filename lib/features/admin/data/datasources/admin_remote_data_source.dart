import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions/admin_exception.dart';
import '../../../auth/data/models/user_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final snapshot = await _usersCollection.orderBy('name').get();

      return snapshot.docs.map((document) {
        return UserModel.fromJson(document.data());
      }).toList();
    } on FirebaseException catch (e) {
      throw AdminException(e.message ?? 'Failed to get users.');
    } catch (_) {
      throw const AdminException('Failed to get users.');
    }
  }
}
