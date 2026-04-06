import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../../../../core/go_router/app_router.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final transactions = ref.watch(transactionNotifierProvider);

  return Scaffold(
    appBar: AppBar(title: const Text('Transactions')),
    body: transactions.isEmpty
        ? const Center(child: Text('No transactions yet'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              return TransactionCard(
                transaction: t,
                onDelete: () => ref
                    .read(transactionNotifierProvider.notifier)
                    .delete(t.id),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.push('/add-transaction'),
      child: const Icon(Icons.add),
    ),
  );
}
}
