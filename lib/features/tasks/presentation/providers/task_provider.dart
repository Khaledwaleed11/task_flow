import 'package:flutter/foundation.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';

enum TaskStatus { initial, loading, loaded, failure }

enum TaskActionStatus { idle, loading, success, failure }

class TaskProvider extends ChangeNotifier {
  final CreateTask createTaskUseCase;
  final GetTasks getTasksUseCase;
  final UpdateTask updateTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final ToggleTaskCompletion toggleTaskCompletionUseCase;

  TaskProvider({
    required this.createTaskUseCase,
    required this.getTasksUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskCompletionUseCase,
  });

  // =========================
  // State
  // =========================

  TaskStatus _status = TaskStatus.initial;

  TaskActionStatus _actionStatus = TaskActionStatus.idle;

  List<TaskEntity> _tasks = [];

  String? _errorMessage;

  String? _actionErrorMessage;

  String? _actionTaskId;

  // =========================
  // Getters
  // =========================

  TaskStatus get status => _status;

  TaskActionStatus get actionStatus => _actionStatus;

  List<TaskEntity> get tasks => List.unmodifiable(_tasks);

  String? get errorMessage => _errorMessage;

  String? get actionErrorMessage => _actionErrorMessage;

  String? get actionTaskId => _actionTaskId;

  bool get isLoading => _status == TaskStatus.loading;

  bool get isActionLoading => _actionStatus == TaskActionStatus.loading;

  bool get hasTasks => _tasks.isNotEmpty;

  int get completedTasksCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get pendingTasksCount {
    return _tasks.where((task) => !task.isCompleted).length;
  }

  // =========================
  // Get Tasks
  // =========================

  Future<void> getTasks({required String projectId}) async {
    _status = TaskStatus.loading;
    _errorMessage = null;

    notifyListeners();

    final result = await getTasksUseCase(GetTasksParams(projectId: projectId));

    result.fold(
      (failure) {
        _status = TaskStatus.failure;
        _errorMessage = failure.message;

        notifyListeners();
      },
      (tasks) {
        _tasks = tasks;
        _status = TaskStatus.loaded;
        _errorMessage = null;

        notifyListeners();
      },
    );
  }

  // =========================
  // Create Task
  // =========================

  Future<bool> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskPriority priority,
  }) async {
    _startAction();

    final result = await createTaskUseCase(
      CreateTaskParams(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);

        return false;
      },
      (task) {
        _tasks = [task, ..._tasks];

        _setActionSuccess();

        return true;
      },
    );
  }

  // =========================
  // Update Task
  // =========================

  Future<bool> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    required bool isCompleted,
  }) async {
    _startAction(taskId: taskId);

    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);

    if (taskIndex == -1) {
      _setActionFailure('Task not found.');

      return false;
    }

    final oldTask = _tasks[taskIndex];

    final result = await updateTaskUseCase(
      UpdateTaskParams(
        projectId: projectId,
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        isCompleted: isCompleted,
        oldIsCompleted: oldTask.isCompleted,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);

        return false;
      },
      (_) {
        _tasks[taskIndex] = TaskEntity(
          id: oldTask.id,
          projectId: oldTask.projectId,
          title: title,
          description: description,
          isCompleted: isCompleted,
          priority: priority,
          createdAt: oldTask.createdAt,
          updatedAt: DateTime.now(),
        );

        _setActionSuccess();

        return true;
      },
    );
  }

  // =========================
  // Delete Task
  // =========================

  Future<bool> deleteTask({
    required String projectId,
    required String taskId,
  }) async {
    _startAction(taskId: taskId);

    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);

    if (taskIndex == -1) {
      _setActionFailure('Task not found.');

      return false;
    }

    final task = _tasks[taskIndex];

    final result = await deleteTaskUseCase(
      DeleteTaskParams(
        projectId: projectId,
        taskId: taskId,
        isCompleted: task.isCompleted,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);

        return false;
      },
      (_) {
        _tasks.removeAt(taskIndex);

        _setActionSuccess();

        return true;
      },
    );
  }

  // =========================
  // Toggle Completion
  // =========================

  Future<bool> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
  }) async {
    _startAction(taskId: taskId);

    final result = await toggleTaskCompletionUseCase(
      ToggleTaskCompletionParams(
        projectId: projectId,
        taskId: taskId,
        isCompleted: isCompleted,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);

        return false;
      },
      (_) {
        final index = _tasks.indexWhere((task) => task.id == taskId);

        if (index != -1) {
          final oldTask = _tasks[index];

          // The value passed to this method is the
          // CURRENT state of the task.
          //
          // The remote data source toggles it to:
          // !isCompleted
          //
          // So we must update the local state
          // with the NEW value as well.
          final newIsCompleted = !isCompleted;

          _tasks[index] = TaskEntity(
            id: oldTask.id,
            projectId: oldTask.projectId,
            title: oldTask.title,
            description: oldTask.description,
            isCompleted: newIsCompleted,
            priority: oldTask.priority,
            createdAt: oldTask.createdAt,
            updatedAt: DateTime.now(),
          );
        }

        _setActionSuccess();

        return true;
      },
    );
  }

  // =========================
  // Action State
  // =========================

  void _startAction({String? taskId}) {
    _actionStatus = TaskActionStatus.loading;

    _actionErrorMessage = null;
    _actionTaskId = taskId;

    notifyListeners();
  }

  void _setActionSuccess() {
    _actionStatus = TaskActionStatus.success;

    _actionErrorMessage = null;
    _actionTaskId = null;

    notifyListeners();
  }

  void _setActionFailure(String message) {
    _actionStatus = TaskActionStatus.failure;

    _actionErrorMessage = message;

    notifyListeners();
  }

  void resetActionStatus() {
    _actionStatus = TaskActionStatus.idle;

    _actionErrorMessage = null;
    _actionTaskId = null;

    notifyListeners();
  }
}
