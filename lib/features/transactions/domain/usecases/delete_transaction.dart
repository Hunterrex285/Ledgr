import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;
  const DeleteTransaction(this.repository);

  Future<void> call(String id) => repository.delete(id);
}
