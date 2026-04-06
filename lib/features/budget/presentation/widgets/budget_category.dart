import 'package:flutter/material.dart';
import 'package:ledgr/features/budget/domain/entites/budget.dart';

class BudgetCategoryTile extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onDelete;

  const BudgetCategoryTile({
    super.key,
    required this.budget,
    required this.spent,
    required this.onDelete,
  });

  Color _categoryColor(String categoryId) {
    final colors = [
      Colors.teal, Colors.indigo, Colors.orange,
      Colors.pink, Colors.purple, Colors.cyan,
    ];
    return colors[categoryId.codeUnitAt(0) % colors.length];
  }

  IconData _categoryIcon(String categoryId) {
    const icons = {
      'Food & Drinks': Icons.restaurant_outlined,
      'Housing': Icons.home_outlined,
      'Transport': Icons.directions_car_outlined,
      'Shopping': Icons.shopping_bag_outlined,
      'Health': Icons.favorite_outline,
      'Entertainment': Icons.movie_outlined,
      'Investment': Icons.trending_up_outlined,
      'Salary': Icons.work_outline,
      'Other': Icons.category_outlined,
    };
    return icons[categoryId] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = budget.limit - spent;
    final isOver = remaining < 0;
    final progress = (spent / budget.limit).clamp(0.0, 1.0);
    final color = _categoryColor(budget.categoryId);

    return Dismissible(
      key: Key(budget.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: const Color.fromARGB(255, 137, 9, 0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(_categoryIcon(budget.categoryId), color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        budget.categoryId,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                      Text(
                        isOver
                            ? '₹${remaining.abs().toStringAsFixed(0)} over'
                            : '₹${remaining.toStringAsFixed(0)} left',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isOver ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${spent.toStringAsFixed(0)} of ₹${budget.limit.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        progress > 0.8 ? Colors.red : color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}