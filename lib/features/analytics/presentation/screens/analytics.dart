import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ledgr/features/analytics/presentation/provider/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  String _monthLabel(DateTime d) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][d.month];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalExpense = ref.watch(monthlyExpenseProvider);
    final categorySpending = ref.watch(categorySpendingProvider);
    final last6 = ref.watch(last6MonthsProvider);
    final weeklyChange = ref.watch(weeklyChangeProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isUp = weeklyChange >= 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Analytics',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Spending summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Spending',
                              style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(
                            '₹${totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 14,
                                color: isUp ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${weeklyChange.abs().toStringAsFixed(1)}% from last week',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isUp ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Mini bar chart
                    SizedBox(
                      width: 80,
                      height: 50,
                      child: last6.isEmpty
                          ? const SizedBox()
                          : BarChart(
                              BarChartData(
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                barGroups: last6.asMap().entries.map((e) {
                                  return BarChartGroupData(x: e.key, barRods: [
                                    BarChartRodData(
                                      toY: e.value.expense,
                                      color: primary,
                                      width: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Month selector + expense total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expense',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(
                        '-₹${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.red),
                      ),
                    ],
                  ),
                  _MonthSelector(
                    selected: selectedMonth,
                    onChanged: (m) =>
                        ref.read(selectedMonthProvider.notifier).state = m,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Area chart
              SizedBox(
                height: 180,
                child: last6.isEmpty
                    ? const Center(child: Text('No data yet'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, _) {
                                  final idx = val.toInt();
                                  if (idx < 0 || idx >= last6.length) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    _monthLabel(last6[idx].month),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: last6.asMap().entries.map((e) {
                                return FlSpot(
                                    e.key.toDouble(), e.value.expense);
                              }).toList(),
                              isCurved: true,
                              color: primary,
                              barWidth: 2.5,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Category breakdown
              const Text('By Category',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              if (categorySpending.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No expenses this month',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ...categorySpending.entries.map((e) => _CategoryRow(
                      category: e.key,
                      amount: e.value,
                      total: totalExpense,
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  const _MonthSelector({required this.selected, required this.onChanged});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selected,
          firstDate: DateTime(now.year - 2),
          lastDate: now,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
        );
        if (picked != null) {
          onChanged(DateTime(picked.year, picked.month, 1));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              '${_months[selected.month - 1]} ${selected.year}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double total;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.total,
  });

  Color _dotColor(String category) {
    final colors = [
      Colors.teal, Colors.indigo, Colors.orange,
      Colors.pink, Colors.purple, Colors.cyan,
    ];
    return colors[category.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _dotColor(category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(category,
                style: const TextStyle(fontSize: 14)),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}