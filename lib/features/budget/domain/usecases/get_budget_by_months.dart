
import 'package:ledgr/features/budget/domain/entites/budget.dart';
import 'package:ledgr/features/budget/domain/repositories/budget_repositories.dart';

class GetBudgetsByMonth {
  final BudgetRepository repository;
  const GetBudgetsByMonth(this.repository);

  Future<List<Budget>> call(DateTime month) => repository.getByMonth(month);
}