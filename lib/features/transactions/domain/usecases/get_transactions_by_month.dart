import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByMonth {
  final TransactionRepository repository;
  const GetTransactionsByMonth(this.repository);

  Future<List<Transaction>> call(DateTime month) => repository.getByMonth(month);
}
