import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final TransactionType type;
  final String? note;
  final bool isRecurring;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.type,
    this.note,
    this.isRecurring = false,
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    TransactionType? type,
    String? note,
    bool? isRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, amount, categoryId, date, type, note, isRecurring];
}
