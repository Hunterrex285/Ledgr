import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

// Monthly summary model
class MonthlySummary {
  final DateTime month;
  final double income;
  final double expense;

  const MonthlySummary({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

// Selected month for analytics — defaults to current month
final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month, 1),
);

// Spending by category for selected month
final categorySpendingProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionNotifierProvider);
  final selectedMonth = ref.watch(selectedMonthProvider);

  final filtered = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.date.year == selectedMonth.year &&
      t.date.month == selectedMonth.month);

  final Map<String, double> result = {};
  for (final t in filtered) {
    result[t.categoryId] = (result[t.categoryId] ?? 0) + t.amount;
  }
  return result;
});

// Total expense for selected month
final monthlyExpenseProvider = Provider<double>((ref) {
  final spending = ref.watch(categorySpendingProvider);
  return spending.values.fold(0.0, (sum, v) => sum + v);
});

// Last 6 months summaries for the bar chart
final last6MonthsProvider = Provider<List<MonthlySummary>>((ref) {
  final transactions = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();

  return List.generate(6, (i) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthlyTransactions = transactions.where((t) =>
        t.date.year == month.year && t.date.month == month.month);

    final income = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final expense = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return MonthlySummary(month: month, income: income, expense: expense);
  }).reversed.toList();
});

// Week over week change
final weeklyChangeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();

  final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

  double thisWeek = 0;
  double lastWeek = 0;

  for (final t in transactions) {
    if (t.type != TransactionType.expense) continue;
    if (t.date.isAfter(thisWeekStart)) {
      thisWeek += t.amount;
    } else if (t.date.isAfter(lastWeekStart) && t.date.isBefore(thisWeekStart)) {
      lastWeek += t.amount;
    }
  }

  if (lastWeek == 0) return 0;
  return ((thisWeek - lastWeek) / lastWeek) * 100;
});