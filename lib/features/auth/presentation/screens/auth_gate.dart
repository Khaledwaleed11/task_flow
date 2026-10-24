import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../admin/presentation/screens/admin_navigation_screen.dart';
import '../../../home/presentation/screens/user_navigation_screen.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();

    Future.microtask(() {
      if (!mounted) return;
      authProvider.checkCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        switch (authProvider.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );

          case AuthStatus.authenticated:
            if (authProvider.user?.role == UserRole.admin) {
              return const AdminNavigationScreen();
            }

            return const UserNavigationScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();
        }
      },
    );
  }
}
