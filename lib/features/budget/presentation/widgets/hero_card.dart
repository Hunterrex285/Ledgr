import 'package:flutter/material.dart';

class BudgetHeroCard extends StatelessWidget {
  final double total;
  final double spent;
  final int daysLeft;

  const BudgetHeroCard({
    super.key,
    required this.total,
    required this.spent,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - spent;
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final isOver = remaining < 0;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Left for $daysLeft days',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${remaining.abs().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isOver ? Colors.red : null,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.8 ? Colors.red : primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${spent.toStringAsFixed(0)} already spent',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text('₹${total.toStringAsFixed(0)} set budget',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}