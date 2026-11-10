
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  // إشعارات محجوزة لـ Cloud Functions.
  final bool isNotifiedBeforeDue;
  final bool isNotifiedAtDue;

  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.isCompleted,
    super.progressStatus = TaskProgressStatus.notStarted,
    required super.priority,
    required super.assignedUserId,
    required super.assignedBy,
    required super.dueDate,
    required super.createdAt,
    required super.updatedAt,
    this.isNotifiedBeforeDue = false,
    this.isNotifiedAtDue = false,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseTimestamp(json['createdAt']) ?? DateTime.now();
    final updatedAt = _parseTimestamp(json['updatedAt']) ?? createdAt;

    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      progressStatus: _progressStatusFromString(json['progressStatus']),
      priority: _priorityFromString(json['priority'] as String? ?? 'medium'),
      assignedUserId: json['assignedUserId'] as String?,
      assignedBy: json['assignedBy'] as String?,
      dueDate: _parseTimestamp(json['dueDate']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isNotifiedBeforeDue: json['isNotifiedBeforeDue'] as bool? ?? false,
      isNotifiedAtDue: json['isNotifiedAtDue'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'progressStatus': progressStatus.name,
      'priority': priority.name,
      'assignedUserId': assignedUserId,
      'assignedBy': assignedBy,

      // لا نكتب الحقل لو فارغ.
      if (dueDate != null) 'dueDate': Timestamp.fromDate(dueDate!),

      'isNotifiedBeforeDue': isNotifiedBeforeDue,
      'isNotifiedAtDue': isNotifiedAtDue,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      progressStatus: entity.progressStatus,
      priority: entity.priority,
      assignedUserId: entity.assignedUserId,
      assignedBy: entity.assignedBy,
      dueDate: entity.dueDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      progressStatus: progressStatus,
      priority: priority,
      assignedUserId: assignedUserId,
      assignedBy: assignedBy,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static TaskPriority _priorityFromString(String value) {
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

  static TaskProgressStatus _progressStatusFromString(dynamic value) {
    switch (value) {
      case 'inProgress':
        return TaskProgressStatus.inProgress;
      case 'notStarted':
      default:
        return TaskProgressStatus.notStarted;
    }
  }
}
