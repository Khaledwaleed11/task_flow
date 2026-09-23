import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../auth/current_user_provider.dart';
import '../auth/firebase_current_user_provider.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/user_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/projects/data/datasources/project_remote_data_source.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/create_project.dart';
import '../../features/projects/domain/usecases/delete_project.dart';
import '../../features/projects/domain/usecases/get_projects.dart';
import '../../features/projects/domain/usecases/update_project.dart';
import '../../features/tasks/data/datasources/task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/tasks/domain/usecases/get_task_by_id.dart';
import '../../features/tasks/domain/usecases/get_tasks.dart';
import '../../features/tasks/domain/usecases/toggle_task_completion.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ============================================================
  // Firebase
  // ============================================================

  sl.registerLazySingleton<FirebaseAuth>(
        () => FirebaseAuth.instance,
  );

  sl.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance,
  );

  // ============================================================
  // Current User
  // ============================================================

  sl.registerLazySingleton<CurrentUserProvider>(
        () => FirebaseCurrentUserProvider(
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  // ============================================================
  // AUTH - Data Sources
  // ============================================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
    ),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // ============================================================
  // AUTH - Repository
  // ============================================================

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      authRemoteDataSource: sl<AuthRemoteDataSource>(),
      userRemoteDataSource: sl<UserRemoteDataSource>(),
    ),
  );

  // ============================================================
  // AUTH - Use Cases
  // ============================================================

  sl.registerLazySingleton<Login>(
        () => Login(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<Register>(
        () => Register(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<Logout>(
        () => Logout(
      sl<AuthRepository>(),
    ),
  );

  sl.registerLazySingleton<GetCurrentUser>(
        () => GetCurrentUser(
      sl<AuthRepository>(),
    ),
  );

  // ============================================================
  // PROJECTS - Data Sources
  // ============================================================

  sl.registerLazySingleton<ProjectRemoteDataSource>(
        () => ProjectRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  // ============================================================
  // PROJECTS - Repository
  // ============================================================

  sl.registerLazySingleton<ProjectRepository>(
        () => ProjectRepositoryImpl(
      remoteDataSource: sl<ProjectRemoteDataSource>(),
      currentUserProvider: sl<CurrentUserProvider>(),
    ),
  );

  // ============================================================
  // PROJECTS - Use Cases
  // ============================================================

  sl.registerLazySingleton<CreateProject>(
        () => CreateProject(
      sl<ProjectRepository>(),
    ),
  );

  sl.registerLazySingleton<GetProjects>(
        () => GetProjects(
      sl<ProjectRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateProject>(
        () => UpdateProject(
      sl<ProjectRepository>(),
    ),
  );

  sl.registerLazySingleton<DeleteProject>(
        () => DeleteProject(
      sl<ProjectRepository>(),
    ),
  );
  // Tasks

  sl.registerLazySingleton<TaskRemoteDataSource>(
        () => TaskRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(
      remoteDataSource: sl<TaskRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<CreateTask>(
        () => CreateTask(
      sl<TaskRepository>(),
    ),
  );

  sl.registerLazySingleton<GetTasks>(
        () => GetTasks(
      sl<TaskRepository>(),
    ),
  );

  sl.registerLazySingleton<GetTaskById>(
        () => GetTaskById(
      sl<TaskRepository>(),
    ),
  );

  sl.registerLazySingleton<UpdateTask>(
        () => UpdateTask(
      sl<TaskRepository>(),
    ),
  );

  sl.registerLazySingleton<DeleteTask>(
        () => DeleteTask(
      sl<TaskRepository>(),
    ),
  );

  sl.registerLazySingleton<ToggleTaskCompletion>(
        () => ToggleTaskCompletion(
      sl<TaskRepository>(),
    ),
  );
}