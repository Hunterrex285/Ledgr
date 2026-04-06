import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgr/features/dashboard/presentation/widgets/recent_transactions.dart';
import '../../../../../features/transactions/domain/entities/transaction.dart';
import '../../../../../features/transactions/presentation/providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionNotifierProvider);

    // All derived — computed from the in-memory list
    final now = DateTime.now();

    final monthlyTransactions = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    final totalIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    final recentTransactions = (transactions.toList()
          ..sort((a, b) => b.date.compareTo(a.date)))
        .take(5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledgr'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(balance: balance),
            const SizedBox(height: 16),
            SummaryRow(totalIncome: totalIncome, totalExpense: totalExpense),
            const SizedBox(height: 24),
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            RecentTransactionsList(transactions: recentTransactions),
          ],
        ),
      ),
    );
  }
}