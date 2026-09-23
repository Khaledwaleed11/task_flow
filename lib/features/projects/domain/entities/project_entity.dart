class ProjectEntity {
  final String id;
  final String ownerId;
  final String name;
  final String description;

  final int totalTasks;
  final int completedTasks;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.totalTasks,
    required this.completedTasks,
    required this.createdAt,
    required this.updatedAt,
  });

  int get pendingTasks {
    return totalTasks - completedTasks;
  }

  double get progress {
    if (totalTasks == 0) {
      return 0;
    }

    return completedTasks / totalTasks;
  }
}
