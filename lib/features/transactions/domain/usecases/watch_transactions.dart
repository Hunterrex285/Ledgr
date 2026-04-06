import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  final TransactionRepository repository;
  const WatchTransactions(this.repository);

  Stream<List<Transaction>> call() => repository.watchAll();
}
