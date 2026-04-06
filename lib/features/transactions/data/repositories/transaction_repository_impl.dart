import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  const TransactionRepositoryImpl(this.localDataSource);

  @override
  Future<List<Transaction>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getByMonth(DateTime month) async {
    final all = await getAll();
    return all
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  @override
  Future<Transaction?> getById(String id) async {
    final all = await getAll();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Transaction transaction) =>
      localDataSource.save(TransactionModel.fromEntity(transaction));

  @override
  Future<void> update(Transaction transaction) =>
      localDataSource.save(TransactionModel.fromEntity(transaction));

  @override
  Future<void> delete(String id) => localDataSource.delete(id);

  @override
  Stream<List<Transaction>> watchAll() => localDataSource
      .watchAll()
      .map((models) => models.map((m) => m.toEntity()).toList());
}
