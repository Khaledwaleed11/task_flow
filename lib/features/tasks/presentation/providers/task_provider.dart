import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_assigned_tasks.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_all_tasks.dart';
import '../../domain/usecases/watch_tasks.dart';

enum TaskStatus { initial, loading, loaded, failure }

enum TaskActionStatus { idle, loading, success, failure }

class TaskProvider extends ChangeNotifier {
  final CreateTask createTaskUseCase;
  final GetTasks getTasksUseCase;
  final GetAssignedTasks getAssignedTasksUseCase;
  final UpdateTask updateTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final ToggleTaskCompletion toggleTaskCompletionUseCase;
  final WatchTasks watchTasksUseCase;
  final WatchAllTasks? watchAllTasksUseCase;

  StreamSubscription? _tasksSubscription;

  TaskProvider({
    required this.createTaskUseCase,
    required this.getTasksUseCase,
    required this.getAssignedTasksUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
    required this.toggleTaskCompletionUseCase,
    required this.watchTasksUseCase,
    this.watchAllTasksUseCase,
  });

  TaskStatus _status = TaskStatus.initial;
  TaskActionStatus _actionStatus = TaskActionStatus.idle;
  List<TaskEntity> _tasks = [];
  String? _errorMessage;
  String? _actionErrorMessage;
  String? _actionTaskId;

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

  void watchTasks({required String projectId}) {
    _tasksSubscription?.cancel();

    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _tasksSubscription =
        watchTasksUseCase(WatchTasksParams(projectId: projectId)).listen(
          (result) {
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
          },
          onError: (_) {
            _status = TaskStatus.failure;
            _errorMessage = 'Failed to watch tasks.';
            notifyListeners();
          },
        );
  }

  void watchAllTasks() {
    if (watchAllTasksUseCase == null) {
      _status = TaskStatus.failure;
      _errorMessage = 'Watch all tasks is not available.';
      notifyListeners();
      return;
    }

    _tasksSubscription?.cancel();

    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    _tasksSubscription = watchAllTasksUseCase!().listen(
      (result) {
        result.fold(
          (failure) {
            debugPrint('WATCH ALL TASKS FAILURE: ${failure.message}');

            _status = TaskStatus.failure;
            _errorMessage = failure.message;
            notifyListeners();
          },
          (tasks) {
            debugPrint('WATCH ALL TASKS PROVIDER COUNT: ${tasks.length}');

            _tasks = tasks;
            _status = TaskStatus.loaded;
            _errorMessage = null;
            notifyListeners();
          },
        );
      },
      onError: (error, stackTrace) {
        debugPrint('WATCH ALL TASKS STREAM ERROR: $error');
        debugPrint('WATCH ALL TASKS STACK TRACE: $stackTrace');

        _status = TaskStatus.failure;
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<void> getAssignedTasks({required String userId}) async {
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getAssignedTasksUseCase(
      GetAssignedTasksParams(userId: userId),
    );

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

  Future<bool> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskPriority priority,
    String? assignedUserId,
  }) async {
    _startAction();

    final result = await createTaskUseCase(
      CreateTaskParams(
        projectId: projectId,
        title: title,
        description: description,
        priority: priority,
        assignedUserId: assignedUserId,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);
        return false;
      },
      (_) {
        _setActionSuccess();
        return true;
      },
    );
  }

  Future<bool> updateTask({
    required String projectId,
    required String taskId,
    required String title,
    required String description,
    required TaskPriority priority,
    String? assignedUserId,
  }) async {
    _startAction(taskId: taskId);

    final result = await updateTaskUseCase(
      UpdateTaskParams(
        projectId: projectId,
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        assignedUserId: assignedUserId,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);
        return false;
      },
      (_) {
        _setActionSuccess();
        return true;
      },
    );
  }

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
        _setActionSuccess();
        return true;
      },
    );
  }

  Future<bool> toggleTaskCompletion({
    required String projectId,
    required String taskId,
    required bool isCompleted,
    required bool updateProjectStats,
  }) async {
    _startAction(taskId: taskId);

    final result = await toggleTaskCompletionUseCase(
      ToggleTaskCompletionParams(
        projectId: projectId,
        taskId: taskId,
        isCompleted: isCompleted,
        updateProjectStats: updateProjectStats,
      ),
    );

    return result.fold(
      (failure) {
        _setActionFailure(failure.message);
        return false;
      },
      (_) {
        final taskIndex = _tasks.indexWhere((task) => task.id == taskId);

        if (taskIndex != -1) {
          final task = _tasks[taskIndex];

          _tasks[taskIndex] = task.copyWith(
            isCompleted: !isCompleted,
            updatedAt: DateTime.now(),
          );
        }

        _setActionSuccess();
        notifyListeners();
        return true;
      },
    );
  }

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
  }

  void resetActionStatus() {
    _actionStatus = TaskActionStatus.idle;
    _actionErrorMessage = null;
    _actionTaskId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
