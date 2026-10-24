
import '../../../../core/dependency_injection/injection_container.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_assigned_tasks.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/watch_all_tasks.dart';
import '../../domain/usecases/watch_assigned_tasks.dart';
import '../../domain/usecases/watch_tasks.dart';
import 'task_provider.dart';

TaskProvider createTaskProvider() {
  return TaskProvider(
    createTaskUseCase: sl<CreateTask>(),
    getTasksUseCase: sl<GetTasks>(),
    getAssignedTasksUseCase: sl<GetAssignedTasks>(),
    updateTaskUseCase: sl<UpdateTask>(),
    deleteTaskUseCase: sl<DeleteTask>(),
    toggleTaskCompletionUseCase: sl<ToggleTaskCompletion>(),
    watchTasksUseCase: sl<WatchTasks>(),
    watchAllTasksUseCase: sl<WatchAllTasks>(),
    watchAssignedTasksUseCase: sl<WatchAssignedTasks>(),
  );
}
