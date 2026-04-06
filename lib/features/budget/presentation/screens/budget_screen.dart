import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgr/features/budget/presentation/widgets/budget_category.dart';
import 'package:ledgr/features/budget/presentation/widgets/hero_card.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetNotifierProvider);
    final spending = ref.watch(monthlySpendingByCategoryProvider);
    final summary = ref.watch(totalBudgetSummaryProvider);

    final now = DateTime.now();
    final monthlyBudgets = budgets
        .where((b) => b.month.year == now.year && b.month.month == now.month)
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () => _showAddBudgetSheet(context, ref),
                    child: const Text('Edit budget'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Hero card
              BudgetHeroCard(
                total: summary.total,
                spent: summary.spent,
                daysLeft: summary.daysLeft,
              ),
              const SizedBox(height: 28),

              // Category list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => _showAddBudgetSheet(context, ref),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (monthlyBudgets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No budgets set for this month',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                ...monthlyBudgets.map((budget) {
                  final spent = spending[budget.categoryId] ?? 0.0;
                  return BudgetCategoryTile(
                    budget: budget,
                    spent: spent,
                    onDelete: () => ref
                        .read(budgetNotifierProvider.notifier)
                        .delete(budget.id),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddBudgetSheet(ref: ref),
    );
  }
}

class _AddBudgetSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddBudgetSheet({required this.ref});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food & Drinks';

  static const _categories = [
    'Food & Drinks', 'Housing', 'Transport', 'Shopping',
    'Health', 'Entertainment', 'Investment', 'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    await widget.ref.read(budgetNotifierProvider.notifier).add(
          categoryId: _selectedCategory,
          limit: amount,
          month: DateTime.now(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Set Budget',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monthly limit',
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Budget', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}