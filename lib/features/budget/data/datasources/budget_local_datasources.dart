import 'package:hive/hive.dart';
import '../models/budget_model.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getAll();
  Future<void> save(BudgetModel model);
  Future<void> delete(String id);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Box<BudgetModel> box;
  const BudgetLocalDataSourceImpl(this.box);

  @override
  Future<List<BudgetModel>> getAll() async => box.values.toList();

  @override
  Future<void> save(BudgetModel model) => box.put(model.id, model);

  @override
  Future<void> delete(String id) => box.delete(id);
}