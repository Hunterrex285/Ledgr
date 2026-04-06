import 'package:flutter/material.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/widgets/transaction_card.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;
  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Text('No transactions this month', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(
      children: transactions
          .map((t) => TransactionCard(transaction: t))
          .toList(),
    );
  }
}