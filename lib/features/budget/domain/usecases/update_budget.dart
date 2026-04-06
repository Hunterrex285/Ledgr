import 'package:ledgr/features/budget/domain/entites/budget.dart';
import 'package:ledgr/features/budget/domain/repositories/budget_repositories.dart';


class UpdateBudget {
  final BudgetRepository repository;
  const UpdateBudget(this.repository);

  Future<void> call(Budget budget) => repository.update(budget);
}