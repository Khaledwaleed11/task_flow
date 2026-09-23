import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
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

    Future.microtask(() {
      context.read<AuthProvider>().checkCurrentUser();
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
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );

          case AuthStatus.authenticated:
            return const HomeScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.failure:
            return const LoginScreen();
        }
      },
    );
  }
}