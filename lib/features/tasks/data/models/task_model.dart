import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.priority,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      priority: _priorityFromString(
        json['priority'] as String,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskModel.fromEntity(
      TaskEntity entity,
      ) {
    return TaskModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
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
      priority: priority,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static TaskPriority _priorityFromString(
      String value,
      ) {
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