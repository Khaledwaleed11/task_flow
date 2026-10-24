
import 'package:flutter/material.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
      elevation: 0,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 76,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
