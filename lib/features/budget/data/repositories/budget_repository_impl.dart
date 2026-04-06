import 'package:ledgr/features/budget/data/datasources/budget_local_datasources.dart';
import 'package:ledgr/features/budget/domain/entites/budget.dart';
import 'package:ledgr/features/budget/domain/repositories/budget_repositories.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  const BudgetRepositoryImpl(this.localDataSource);

  @override
  Future<List<Budget>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Budget>> getByMonth(DateTime month) async {
    final all = await getAll();
    return all
        .where((b) => b.month.year == month.year && b.month.month == month.month)
        .toList();
  }

  @override
  Future<void> add(Budget budget) =>
      localDataSource.save(BudgetModel.fromEntity(budget));

  @override
  Future<void> update(Budget budget) =>
      localDataSource.save(BudgetModel.fromEntity(budget));

  @override
  Future<void> delete(String id) => localDataSource.delete(id);
}