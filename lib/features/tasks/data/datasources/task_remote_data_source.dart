import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/error/exceptions/task_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskModel> createTask({
    required String projectId,
    required String title,
    required String description,
    required String priority,
    String? assignedUserId,
    DateTime? dueDate,
    String? assignedBy,
  });

  Future<List<TaskModel>> getTasks({required String projectId});

  Stream<List<TaskModel>> watchTasks({required String projectId});

  Stream<List<TaskModel>> watchAllTasks();

  Stream<List<TaskModel>> watchAssignedTasks({required String userId});

  Future<List<TaskModel>> getAssignedTasks({required String userId});

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
    String? assignedUserId,
    DateTime? dueDate,
    String? assignedBy,
  });

  Future<void> deleteTask({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  });
  Future<void> startTask({
    required String projectId,
    required String taskId,
  });
  Future<void> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
    required bool updateProjectStats,
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
    String? assignedUserId,
    DateTime? dueDate,
    String? assignedBy,
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
        assignedUserId: assignedUserId,
        assignedBy: assignedUserId == null ? null : assignedBy,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
      );

      final batch = firestore.batch();

      batch.set(taskDocument, task.toJson());

      batch.update(projectDocument, {
        'totalTasks': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (assignedUserId != null && assignedUserId.isNotEmpty) {
        await _syncProjectAssignedUsers(projectId);
      }

      return task;
    } on FirebaseException catch (e) {
      debugPrint(
        'CREATE TASK FIREBASE ERROR: ${e.code} - ${e.message}',
      );
      throw TaskException(
        'Firebase ${e.code}: ${e.message ?? 'Failed to create task.'}',
      );
    } catch (e) {
      debugPrint('CREATE TASK ERROR: $e');
      throw TaskException('Failed to create task: $e');
    }
  }
  @override
  Future<void> startTask({
    required String projectId,
    required String taskId,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc(taskId);

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(taskDocument);

        if (!snapshot.exists) {
          throw const TaskException('Task not found.');
        }

        final data = snapshot.data();

        if (data == null) {
          throw const TaskException('Task data not found.');
        }

        if (data['isCompleted'] == true) {
          throw const TaskException('Completed tasks cannot be started.');
        }

        transaction.update(taskDocument, {
          'progressStatus': TaskProgressStatus.inProgress.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on TaskException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TaskException(
        e.message ?? 'Failed to start task.',
      );
    } catch (e) {
      throw TaskException('Failed to start task: $e');
    }
  }
  Future<void> _syncProjectAssignedUsers(String projectId) async {
    final taskSnapshot = await _tasksCollection(projectId).get();

    final assignedUserIds = taskSnapshot.docs
        .map((document) => document.data()['assignedUserId'])
        .whereType<String>()
        .where((userId) => userId.isNotEmpty)
        .toSet()
        .toList();

    await _projectDocument(projectId).update({
      'assignedUserIds': assignedUserIds,
    });
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
  Stream<List<TaskModel>> watchTasks({required String projectId}) {
    return _tasksCollection(projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return TaskModel.fromJson(document.data());
          }).toList();
        });
  }

  @override
  Stream<List<TaskModel>> watchAllTasks() {
    return firestore.collectionGroup('tasks').snapshots().map((snapshot) {
      final tasks = snapshot.docs.map((document) {
        final data = document.data();

        debugPrint(
          'TASK => path: ${document.reference.path} | '
          'id: ${document.id} | '
          'projectId: ${data['projectId']} | '
          'title: ${data['title']} | '
          'isCompleted: ${data['isCompleted']}',
        );

        return TaskModel.fromJson(data);
      }).toList();

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('WATCH ALL TASKS COUNT: ${tasks.length}');

      return tasks;
    });
  }

  @override
  Stream<List<TaskModel>> watchAssignedTasks({required String userId}) {
    return firestore
        .collectionGroup('tasks')
        .where('assignedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return TaskModel.fromJson(document.data());
          }).toList();
        });
  }

  @override
  Future<List<TaskModel>> getAssignedTasks({required String userId}) async {
    try {
      final snapshot = await firestore
          .collectionGroup('tasks')
          .where('assignedUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((document) {
        return TaskModel.fromJson(document.data());
      }).toList();
    } on FirebaseException catch (e) {
      throw TaskException(e.message ?? 'Failed to get assigned tasks.');
    } catch (_) {
      throw const TaskException('Failed to get assigned tasks.');
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
    String? assignedUserId,
    DateTime? dueDate,
    String? assignedBy,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc(taskId);
      final existing = await taskDocument.get();
      final previousAssignee = existing.data()?['assignedUserId'] as String?;

      await taskDocument.update({
        'title': title,
        'description': description,
        'priority': priority,
        'assignedUserId': assignedUserId,
        if (dueDate == null) 'dueDate': FieldValue.delete(),
        if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate),
        if (assignedUserId != null &&
            assignedBy != null &&
            assignedUserId != previousAssignee)
          'assignedBy': assignedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _syncProjectAssignedUsers(projectId);
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

      batch.delete(taskDocument);

      final projectUpdates = <String, dynamic>{
        'totalTasks': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isCompleted) {
        projectUpdates['completedTasks'] = FieldValue.increment(-1);
      }

      batch.update(projectDocument, projectUpdates);

      await batch.commit();
      await _syncProjectAssignedUsers(projectId);
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
    required bool updateProjectStats,
  }) async {
    try {
      final taskDocument = _tasksCollection(projectId).doc(taskId);
      final newIsCompleted = !isCompleted;

      if (!updateProjectStats) {
        await taskDocument.update({
          'isCompleted': newIsCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final projectDocument = _projectDocument(projectId);
      final batch = firestore.batch();

      batch.update(taskDocument, {
        'isCompleted': newIsCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

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
