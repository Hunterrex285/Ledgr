import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction {
  final TransactionRepository repository;
  const AddTransaction(this.repository);

  Future<void> call(Transaction transaction) => repository.add(transaction);
}
