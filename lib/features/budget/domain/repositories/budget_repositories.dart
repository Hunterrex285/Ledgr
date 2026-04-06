

import 'package:ledgr/features/budget/domain/entites/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAll();
  Future<List<Budget>> getByMonth(DateTime month);
  Future<void> add(Budget budget);
  Future<void> update(Budget budget);
  Future<void> delete(String id);
}