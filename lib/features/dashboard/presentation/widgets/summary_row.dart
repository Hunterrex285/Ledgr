import 'package:flutter/material.dart';

class SummaryRow extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  const SummaryRow({super.key, required this.totalIncome, required this.totalExpense});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SummaryCard(label: 'Income', amount: totalIncome, color: Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(label: 'Expenses', amount: totalExpense, color: Colors.red)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _SummaryCard({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 13)),
          const SizedBox(height: 4),
          Text('₹${amount.toStringAsFixed(0)}',
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}