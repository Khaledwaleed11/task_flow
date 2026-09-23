import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/dependency_injection/injection_container.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/projects/presentation/providers/project_provider.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: sl(),
            registerUseCase: sl(),
            logoutUseCase: sl(),
            getCurrentUserUseCase: sl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(
            createProjectUseCase: sl(),
            getProjectsUseCase: sl(),
            updateProjectUseCase: sl(),
            deleteProjectUseCase: sl(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TaskFlow',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}