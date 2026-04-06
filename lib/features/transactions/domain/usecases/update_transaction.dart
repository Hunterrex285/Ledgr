import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;
  const UpdateTransaction(this.repository);

  Future<void> call(Transaction transaction) => repository.update(transaction);
}
