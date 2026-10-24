enum TaskPriority { low, medium, high }

class TaskEntity {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final String? assignedUserId;
  final String? assignedBy;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.assignedUserId,
    required this.assignedBy,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    String? assignedUserId,
    String? assignedBy,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedBy: assignedBy ?? this.assignedBy,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
