import 'package:ledgr/features/budget/domain/entites/budget.dart';
import 'package:ledgr/features/budget/domain/repositories/budget_repositories.dart';

class AddBudget {
  final BudgetRepository repository;
  const AddBudget(this.repository);

  Future<void> call(Budget budget) => repository.add(budget);
}