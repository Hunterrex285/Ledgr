import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/update_transaction.dart';

// Use case providers — overridden in injection_container.dart at app startup
final addTransactionProvider =
    Provider<AddTransaction>((ref) => throw UnimplementedError());
final deleteTransactionProvider =
    Provider<DeleteTransaction>((ref) => throw UnimplementedError());
final updateTransactionProvider =
    Provider<UpdateTransaction>((ref) => throw UnimplementedError());

final transactionNotifierProvider =
    NotifierProvider<TransactionNotifier, List<Transaction>>(
      TransactionNotifier.new,
    );

// Notifier — manages in-memory list, syncs to Hive in background
class TransactionNotifier extends Notifier<List<Transaction>> {
  @override
  List<Transaction> build() => [];

  Future<void> add({
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    required TransactionType type,
    String? note,
    bool isRecurring = false,
  }) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      categoryId: categoryId,
      date: date,
      type: type,
      note: note,
      isRecurring: isRecurring,
    );
    state = [...state, transaction];                  // UI updates instantly
    await ref.read(addTransactionProvider)(transaction); // Hive persists in background
  }

  Future<void> delete(String id) async {
    state = state.where((t) => t.id != id).toList();
    await ref.read(deleteTransactionProvider)(id);
  }

  Future<void> update(Transaction transaction) async {
    state = state.map((t) => t.id == transaction.id ? transaction : t).toList();
    await ref.read(updateTransactionProvider)(transaction);
  }
}

