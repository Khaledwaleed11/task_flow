import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/error/exceptions/app_exception.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> createProject({
    required String ownerId,
    required String name,
    required String description,
  });

  Future<List<ProjectModel>> getProjects({required String ownerId});

  Future<ProjectModel?> getProjectById({
    required String ownerId,
    required String projectId,
  });

  Future<void> updateProject({
    required String ownerId,
    required String projectId,
    required String name,
    required String description,
  });

  Future<void> deleteProject({
    required String ownerId,
    required String projectId,
  });
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore firestore;

  ProjectRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _projectsCollection =>
      firestore.collection('projects');

  @override
  Future<ProjectModel> createProject({
    required String ownerId,
    required String name,
    required String description,
  }) async {
    try {
      final document = _projectsCollection.doc();

      final now = DateTime.now();

      final project = ProjectModel(
        id: document.id,
        ownerId: ownerId,
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
        totalTasks: 0,
        completedTasks: 0,
      );

      await document.set(project.toJson());

      return project;
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to create project.');
    } catch (_) {
      throw const AppException('Failed to create project.');
    }
  }

  @override
  Future<List<ProjectModel>> getProjects({required String ownerId}) async {
    try {
      final snapshot = await _projectsCollection
          .where('ownerId', isEqualTo: ownerId)
          .get();

      return snapshot.docs.map((document) {
        return ProjectModel.fromJson(document.data());
      }).toList();
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to get projects.');
    } catch (_) {
      throw const AppException('Failed to get projects.');
    }
  }

  @override
  Future<ProjectModel?> getProjectById({
    required String ownerId,
    required String projectId,
  }) async {
    try {
      final document = await _projectsCollection.doc(projectId).get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      final project = ProjectModel.fromJson(document.data()!);

      if (project.ownerId != ownerId) {
        return null;
      }

      return project;
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to get project.');
    } catch (_) {
      throw const AppException('Failed to get project.');
    }
  }

  @override
  Future<void> updateProject({
    required String ownerId,
    required String projectId,
    required String name,
    required String description,
  }) async {
    try {
      await _projectsCollection.doc(projectId).update({
        'name': name,
        'description': description,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw AppException(e.message ?? 'Failed to update project.');
    } catch (_) {
      throw const AppException('Failed to update project.');
    }
  }

  @override
  Future<void> deleteProject({
    required String ownerId,
    required String projectId,
  }) async {
    try {
      final document =
      _projectsCollection.doc(projectId);

      debugPrint(
        'DELETE PROJECT: ${document.path}',
      );

      await document.delete();

      debugPrint(
        'DELETE PROJECT SUCCESS: ${document.path}',
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'DELETE PROJECT FIREBASE ERROR: '
            '${e.code} - ${e.message}',
      );

      throw AppException(
        e.message ?? 'Failed to delete project.',
      );
    } catch (e) {
      debugPrint(
        'DELETE PROJECT ERROR: $e',
      );

      throw AppException(
        e.toString(),
      );
    }
  }
}
