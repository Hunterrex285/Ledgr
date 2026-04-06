import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

// After adding this file run: flutter pub run build_runner build
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final double amount;
  @HiveField(3) final String categoryId;
  @HiveField(4) final DateTime date;
  @HiveField(5) final int typeIndex; // 0 = income, 1 = expense
  @HiveField(6) final String? note;
  @HiveField(7) final bool isRecurring;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.typeIndex,
    this.note,
    this.isRecurring = false,
  });

  // Model → Entity
  Transaction toEntity() => Transaction(
    id: id,
    title: title,
    amount: amount,
    categoryId: categoryId,
    date: date,
    type: TransactionType.values[typeIndex],
    note: note,
    isRecurring: isRecurring,
  );

  // Entity → Model
  factory TransactionModel.fromEntity(Transaction t) => TransactionModel(
    id: t.id,
    title: t.title,
    amount: t.amount,
    categoryId: t.categoryId,
    date: t.date,
    typeIndex: t.type.index,
    note: t.note,
    isRecurring: t.isRecurring,
  );
}
