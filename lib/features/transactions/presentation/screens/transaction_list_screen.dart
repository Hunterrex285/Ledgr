import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transaction_provider.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/transaction_card.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum SortOption { newest, oldest, highest, lowest }

enum TimePeriod { all, today, thisWeek, thisMonth, thisYear }

// ── Constants ─────────────────────────────────────────────────────────────────

const _categories = [
  'Food & Drinks',
  'Housing',
  'Transport',
  'Shopping',
  'Health',
  'Entertainment',
  'Investment',
  'Salary',
  'Other',
];

// ── Screen ───────────────────────────────────────────────────────────────────

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends ConsumerState<TransactionListScreen> {
  TransactionType? _typeFilter;
  SortOption _sort = SortOption.newest;
  TimePeriod _period = TimePeriod.all;
  final Set<String> _selectedCategories = {};

  // ── Filtering & Sorting ──────────────────────────────────────────────────

  List<Transaction> _applyFiltersAndSort(List<Transaction> txns) {
    final now = DateTime.now();

    return txns.where((t) {
      // Type filter
      if (_typeFilter != null && t.type != _typeFilter) return false;

      // Category filter
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(t.categoryId)) return false;

      // Time period filter
      switch (_period) {
        case TimePeriod.today:
          if (!_isSameDay(t.date, now)) return false;
        case TimePeriod.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          if (t.date.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day))) return false;
        case TimePeriod.thisMonth:
          if (t.date.month != now.month || t.date.year != now.year) return false;
        case TimePeriod.thisYear:
          if (t.date.year != now.year) return false;
        case TimePeriod.all:
          break;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sort) {
          case SortOption.newest:
            return b.date.compareTo(a.date);
          case SortOption.oldest:
            return a.date.compareTo(b.date);
          case SortOption.highest:
            return b.amount.compareTo(a.amount);
          case SortOption.lowest:
            return a.amount.compareTo(b.amount);
        }
      });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Bottom Sheet ─────────────────────────────────────────────────────────

  void _showFilterSortSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSortSheet(
        currentSort: _sort,
        currentPeriod: _period,
        selectedCategories: Set.from(_selectedCategories),
        onApply: (sort, period, cats) {
          setState(() {
            _sort = sort;
            _period = period;
            _selectedCategories
              ..clear()
              ..addAll(cats);
          });
        },
      ),
    );
  }

  // ── Grouping ─────────────────────────────────────────────────────────────

  Map<String, List<Transaction>> _groupByDate(List<Transaction> txns) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final Map<String, List<Transaction>> grouped = {};

    for (final t in txns) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      String label;
      if (d == today) {
        label = 'TODAY';
      } else if (d == yesterday) {
        label = 'YESTERDAY';
      } else {
        label = '${_monthName(t.date.month)} ${t.date.day}, ${t.date.year}';
      }
      grouped.putIfAbsent(label, () => []).add(t);
    }
    return grouped;
  }

  // ── Active filter count badge ─────────────────────────────────────────────

  int get _activeFilterCount {
    int count = 0;
    if (_period != TimePeriod.all) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_sort != SortOption.newest) count++;
    return count;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionNotifierProvider);
    final filtered = _applyFiltersAndSort(transactions);
    final grouped = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FAF4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Colors.grey.shade600),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Type Filter Tabs + Filter Button Row ──
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Expanded(
                  child: _TypeFilterTabs(
                    selected: _typeFilter,
                    onSelected: (t) => setState(() => _typeFilter = t),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  activeCount: _activeFilterCount,
                  onTap: _showFilterSortSheet,
                ),
              ],
            ),
          ),

          // ── Active filter chips ──
          if (_selectedCategories.isNotEmpty || _period != TimePeriod.all)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _ActiveFilterChips(
                period: _period,
                categories: _selectedCategories,
                onRemovePeriod: () => setState(() => _period = TimePeriod.all),
                onRemoveCategory: (c) =>
                    setState(() => _selectedCategories.remove(c)),
              ),
            ),


          // ── List ──
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _countItems(grouped),
                    itemBuilder: (context, index) =>
                        _buildItem(grouped, index, ref),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: const Color(0xFF4CD9A0),
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  int _countItems(Map<String, List<Transaction>> grouped) {
    int count = 0;
    for (final list in grouped.values) {
      count += 1 + list.length;
    }
    return count;
  }

  Widget _buildItem(
      Map<String, List<Transaction>> grouped, int index, WidgetRef ref) {
    int cursor = 0;
    for (final entry in grouped.entries) {
      if (index == cursor) {
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.8,
            ),
          ),
        );
      }
      cursor++;
      for (final t in entry.value) {
        if (index == cursor) {
          return TransactionCard(
            transaction: t,
            onDelete: () =>
                ref.read(transactionNotifierProvider.notifier).delete(t.id),
          );
        }
        cursor++;
      }
    }
    return const SizedBox.shrink();
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// ── Type Filter Tabs ──────────────────────────────────────────────────────────

class _TypeFilterTabs extends StatelessWidget {
  final TransactionType? selected;
  final ValueChanged<TransactionType?> onSelected;

  const _TypeFilterTabs({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final tabs = <String, TransactionType?>{
      'All': null,
      'Income': TransactionType.income,
      'Expense': TransactionType.expense,
    };

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: tabs.entries.map((e) {
          final isSelected = selected == e.value;
          return GestureDetector(
            onTap: () => onSelected(e.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4CD9A0)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CD9A0)
                      : Colors.grey.shade200,
                ),
              ),
              child: Text(
                e.key,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Filter Button ─────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: activeCount > 0
                  ? const Color(0xFF4CD9A0).withOpacity(0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: activeCount > 0
                    ? const Color(0xFF4CD9A0)
                    : Colors.grey.shade200,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 18,
              color: activeCount > 0
                  ? const Color(0xFF4CD9A0)
                  : Colors.grey.shade500,
            ),
          ),
          if (activeCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CD9A0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Active Filter Chips ───────────────────────────────────────────────────────

class _ActiveFilterChips extends StatelessWidget {
  final TimePeriod period;
  final Set<String> categories;
  final VoidCallback onRemovePeriod;
  final ValueChanged<String> onRemoveCategory;

  const _ActiveFilterChips({
    required this.period,
    required this.categories,
    required this.onRemovePeriod,
    required this.onRemoveCategory,
  });

  String _periodLabel(TimePeriod p) {
    switch (p) {
      case TimePeriod.today:
        return 'Today';
      case TimePeriod.thisWeek:
        return 'This Week';
      case TimePeriod.thisMonth:
        return 'This Month';
      case TimePeriod.thisYear:
        return 'This Year';
      case TimePeriod.all:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (period != TimePeriod.all)
            _Chip(label: _periodLabel(period), onRemove: onRemovePeriod),
          ...categories.map(
            (c) => _Chip(label: c, onRemove: () => onRemoveCategory(c)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _Chip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CD9A0).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CD9A0).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF27AE60),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 13, color: Color(0xFF27AE60)),
          ),
        ],
      ),
    );
  }
}

// ── Filter & Sort Bottom Sheet ────────────────────────────────────────────────

class _FilterSortSheet extends StatefulWidget {
  final SortOption currentSort;
  final TimePeriod currentPeriod;
  final Set<String> selectedCategories;
  final void Function(SortOption, TimePeriod, Set<String>) onApply;

  const _FilterSortSheet({
    required this.currentSort,
    required this.currentPeriod,
    required this.selectedCategories,
    required this.onApply,
  });

  @override
  State<_FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<_FilterSortSheet> {
  late SortOption _sort;
  late TimePeriod _period;
  late Set<String> _cats;

  @override
  void initState() {
    super.initState();
    _sort = widget.currentSort;
    _period = widget.currentPeriod;
    _cats = Set.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort & Filter',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sort = SortOption.newest;
                    _period = TimePeriod.all;
                    _cats.clear();
                  });
                },
                child: const Text(
                  'Reset all',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4CD9A0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Sort ──
          _SheetSection(
            title: 'Sort by',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SortOption.values.map((s) {
                final labels = {
                  SortOption.newest: 'Newest first',
                  SortOption.oldest: 'Oldest first',
                  SortOption.highest: 'Highest amount',
                  SortOption.lowest: 'Lowest amount',
                };
                return _SelectChip(
                  label: labels[s]!,
                  selected: _sort == s,
                  onTap: () => setState(() => _sort = s),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Time Period ──
          _SheetSection(
            title: 'Time period',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimePeriod.values.map((p) {
                final labels = {
                  TimePeriod.all: 'All time',
                  TimePeriod.today: 'Today',
                  TimePeriod.thisWeek: 'This week',
                  TimePeriod.thisMonth: 'This month',
                  TimePeriod.thisYear: 'This year',
                };
                return _SelectChip(
                  label: labels[p]!,
                  selected: _period == p,
                  onTap: () => setState(() => _period = p),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ── Categories ──
          _SheetSection(
            title: 'Categories',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final selected = _cats.contains(c);
                return _SelectChip(
                  label: c,
                  selected: selected,
                  onTap: () => setState(() {
                    selected ? _cats.remove(c) : _cats.add(c);
                  }),
                  multiSelect: true,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),

          // Apply button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_sort, _period, _cats);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CD9A0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sheet Section ─────────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// ── Select Chip ───────────────────────────────────────────────────────────────

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multiSelect;

  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4CD9A0).withOpacity(0.12)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF4CD9A0)
                : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? const Color(0xFF27AE60)
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}