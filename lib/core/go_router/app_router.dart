import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ledgr/features/analytics/presentation/screens/analytics.dart';
import 'package:ledgr/features/budget/presentation/screens/budget_screen.dart';
import 'package:ledgr/features/ious/presentation/screens/iou_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../shell/main_shell.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';

final _shellNavigatorHome        = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorTransactions = GlobalKey<NavigatorState>(debugLabel: 'transactions');
final _shellNavigatorBudget      = GlobalKey<NavigatorState>(debugLabel: 'budget');
final _shellNavigatorAnalytics   = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _shellNavigatorIou         = GlobalKey<NavigatorState>(debugLabel: 'iou');

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHome,
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTransactions,
          routes: [
            GoRoute(path: '/transactions', builder: (_, __) => const TransactionListScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBudget,
          routes: [
            GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAnalytics,
          routes: [
            GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorIou,
          routes: [
            GoRoute(path: '/iou', builder: (_, __) => const IouScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (_, __) => const AddTransactionScreen(),
    ),
  ],
);