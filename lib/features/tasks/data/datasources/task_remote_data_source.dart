import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions/task_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskModel> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
  });

  Future<List<TaskModel>> getTasks({required String projectId});

  Future<TaskModel?> getTaskById({
    required String projectId,
    required String taskId,
  });

  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required String priority,
    required bool isCompleted,

    // حالة الـ Task قبل التعديل
    required bool oldIsCompleted,
  });

  Future<void> deleteTask({
    required String projectId,
    required String taskId,

    // هل الـ Task كانت مكتملة قبل الحذف؟
    required bool isCompleted,
  });

  Future<void> toggleTaskCompletion({
    required String projectId,
    required String taskId,

    // الحالة الحالية للـ Task
    required bool isCompleted,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _tasksCollection(String projectId) {
    return firestore.collection('projects').doc(projectId).collection('tasks');
  }

  DocumentReference<Map<String, dynamic>> _projectDocument(String projectId) {
    return firestore.collection('projects').doc(projectId);
  }

  @override
  Future<TaskModel> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc();
      final projectDocument = _projectDocument(projectId);

      final now = DateTime.now();

      final task = TaskModel(
        id: taskDocument.id,
        projectId: projectId,
        title: title,
        description: description,
        isCompleted: false,
        priority: _priorityFromString(priority),
        createdAt: now,
        updatedAt: now,
      );

      final batch = firestore.batch();

      // Create Task
      batch.set(taskDocument, task.toJson());

      // Increase total tasks count
      batch.update(projectDocument, {
        'totalTasks': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      return task;
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to create task.');
    } catch (_) {
      throw const TaskException('Failed to create task.');
    }
  }

  @override
  Future<List<TaskModel>> getTasks({required String projectId}) async {
    try {
      final snapshot = await _tasksCollection(projectId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((document) {
        return TaskModel.fromJson(document.data());
      }).toList();
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to get tasks.');
    } catch (_) {
      throw const TaskException('Failed to get tasks.');
    }
  }

  @override
  Future<TaskModel?> getTaskById({
    required String projectId,
    required String taskId,
  }) async {
    try {
      final document = await _tasksCollection(projectId).doc(taskId).get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      return TaskModel.fromJson(document.data()!);
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to get task.');
    } catch (_) {
      throw const TaskException('Failed to get task.');
    }
  }

  @override
  Future<void> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required String priority,
    required bool isCompleted,
    required bool oldIsCompleted,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc(taskId);
      final projectDocument = _projectDocument(projectId);

      final batch = firestore.batch();

      // Update Task
      batch.update(taskDocument, {
        'title': title,
        'description': description,
        'priority': priority,
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update completed tasks count
      // only if completion status changed.
      if (oldIsCompleted != isCompleted) {
        final completedChange = isCompleted ? 1 : -1;

        batch.update(projectDocument, {
          'completedTasks': FieldValue.increment(completedChange),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to update task.');
    } catch (_) {
      throw const TaskException('Failed to update task.');
    }
  }

  @override
  Future<void> deleteTask({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc(taskId);
      final projectDocument = _projectDocument(projectId);

      final batch = firestore.batch();

      // Delete Task
      batch.delete(taskDocument);

      // Update Project statistics
      final projectUpdates = <String, dynamic>{
        'totalTasks': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // If the deleted task was completed,
      // decrease completed tasks count.
      if (isCompleted) {
        projectUpdates['completedTasks'] = FieldValue.increment(-1);
      }

      batch.update(projectDocument, projectUpdates);

      await batch.commit();
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to delete task.');
    } catch (_) {
      throw const TaskException('Failed to delete task.');
    }
  }

  @override
  Future<void> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc(taskId);
      final projectDocument = _projectDocument(projectId);

      // The value coming from the UI is the CURRENT state.
      // Therefore we need to switch it.
      final newIsCompleted = !isCompleted;

      final batch = firestore.batch();

      // Update Task
      batch.update(taskDocument, {
        'isCompleted': newIsCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Project statistics based on NEW state.
      final completedChange = newIsCompleted ? 1 : -1;

      batch.update(projectDocument, {
        'completedTasks': FieldValue.increment(completedChange),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to update task status.');
    } catch (_) {
      throw const TaskException('Failed to update task status.');
    }
  }

  TaskPriority _priorityFromString(String value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;

      case 'high':
        return TaskPriority.high;

      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}
