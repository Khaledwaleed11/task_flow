
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependency_injection/injection_container.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../tasks/presentation/screens/admin_tasks_screen.dart';
import '../providers/admin_user_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() =>
      _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const AdminDashboardScreen(),
    const ProjectsScreen(showBackButton: false),
    const AdminTasksScreen(),
    ChangeNotifierProvider<AdminUserProvider>(
      create: (_) => sl<AdminUserProvider>(),
      child: AdminUsersScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}
