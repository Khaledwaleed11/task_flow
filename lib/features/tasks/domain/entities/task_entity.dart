enum TaskPriority {
  low,
  medium,
  high,
}

class TaskEntity {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });
}