import 'package:ledgr/features/budget/domain/repositories/budget_repositories.dart';


class DeleteBudget {
  final BudgetRepository repository;
  const DeleteBudget(this.repository);

  Future<void> call(String id) => repository.delete(id);
}