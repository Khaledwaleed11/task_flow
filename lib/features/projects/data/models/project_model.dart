import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    required super.totalTasks,
    required super.completedTasks,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,

      totalTasks: (json['totalTasks'] as num?)?.toInt() ?? 0,

      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,

      createdAt: (json['createdAt'] as Timestamp).toDate(),

      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,

      'totalTasks': totalTasks,
      'completedTasks': completedTasks,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      ownerId: entity.ownerId,
      name: entity.name,
      description: entity.description,

      totalTasks: entity.totalTasks,
      completedTasks: entity.completedTasks,

      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,

      totalTasks: totalTasks,
      completedTasks: completedTasks,

      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
