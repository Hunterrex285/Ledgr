import 'package:hive/hive.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getAll();
  Future<void> save(TransactionModel model);
  Future<void> delete(String id);
  Stream<List<TransactionModel>> watchAll();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Box<TransactionModel> box;
  const TransactionLocalDataSourceImpl(this.box);

  @override
  Future<List<TransactionModel>> getAll() async => box.values.toList();

  @override
  Future<void> save(TransactionModel model) => box.put(model.id, model);

  @override
  Future<void> delete(String id) => box.delete(id);

  @override
  Stream<List<TransactionModel>> watchAll() =>
      box.watch().map((_) => box.values.toList());
}
