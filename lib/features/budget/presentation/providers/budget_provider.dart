import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgr/features/budget/domain/entites/budget.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/add_budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/update_budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

// Use case providers — overridden in DI
final addBudgetProvider =
    Provider<AddBudget>((ref) => throw UnimplementedError());
final deleteBudgetProvider =
    Provider<DeleteBudget>((ref) => throw UnimplementedError());
final updateBudgetProvider =
    Provider<UpdateBudget>((ref) => throw UnimplementedError());

// Budget notifier
class BudgetNotifier extends Notifier<List<Budget>> {
  @override
  List<Budget> build() => [];

  Future<void> add({
    required String categoryId,
    required double limit,
    required DateTime month,
  }) async {
    final budget = Budget(
      id: const Uuid().v4(),
      categoryId: categoryId,
      limit: limit,
      month: DateTime(month.year, month.month, 1),
    );
    state = [...state, budget];
    await ref.read(addBudgetProvider)(budget);
  }

  Future<void> update(Budget budget) async {
    state = state.map((b) => b.id == budget.id ? budget : b).toList();
    await ref.read(updateBudgetProvider)(budget);
  }

  Future<void> delete(String id) async {
    state = state.where((b) => b.id != id).toList();
    await ref.read(deleteBudgetProvider)(id);
  }
}

final budgetNotifierProvider =
    NotifierProvider<BudgetNotifier, List<Budget>>(BudgetNotifier.new);

// Derived provider — spent per category this month
// Reads transactions directly, no separate storage
final monthlySpendingByCategoryProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();

  final monthlyExpenses = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.date.year == now.year &&
      t.date.month == now.month);

  final Map<String, double> spending = {};
  for (final t in monthlyExpenses) {
    spending[t.categoryId] = (spending[t.categoryId] ?? 0) + t.amount;
  }
  return spending;
});

// Total remaining this month across all budgets
final totalBudgetSummaryProvider = Provider<({double total, double spent, int daysLeft})>((ref) {
  final budgets = ref.watch(budgetNotifierProvider);
  final spending = ref.watch(monthlySpendingByCategoryProvider);
  final now = DateTime.now();

  final monthlyBudgets = budgets.where((b) =>
      b.month.year == now.year && b.month.month == now.month).toList();

  final total = monthlyBudgets.fold(0.0, (sum, b) => sum + b.limit);
  final spent = spending.values.fold(0.0, (sum, v) => sum + v);

  final lastDay = DateTime(now.year, now.month + 1, 0).day;
  final daysLeft = lastDay - now.day;

  return (total: total, spent: spent, daysLeft: daysLeft);
});