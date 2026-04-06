import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),     selectedIcon: Icon(Icons.home),     label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_outlined),  selectedIcon: Icon(Icons.receipt),  label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart),label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined),selectedIcon: Icon(Icons.bar_chart),label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined),selectedIcon: Icon(Icons.handshake),label: 'IOUs'),
        ],
      ),
    );
  }
}