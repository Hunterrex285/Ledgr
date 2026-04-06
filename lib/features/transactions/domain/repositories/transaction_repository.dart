import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAll();
  Future<List<Transaction>> getByMonth(DateTime month);
  Future<Transaction?> getById(String id);
  Future<void> add(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Stream<List<Transaction>> watchAll();
}
