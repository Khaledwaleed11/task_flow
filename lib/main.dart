import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/dependency_injection/injection_container.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDependencies();

  final themeProvider = ThemeProvider();

  await themeProvider.loadTheme();

  runApp(
    TaskFlowApp(
      themeProvider: themeProvider,
    ),
  );
}