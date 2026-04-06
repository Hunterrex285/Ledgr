import 'package:equatable/equatable.dart';

enum IouType { lent, borrowed }

class Iou extends Equatable {
  final String id;
  final String personName;
  final double amount;
  final IouType type;
  final DateTime date;
  final String? note;
  final bool isSettled;

  const Iou({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.isSettled = false,
  });

  Iou copyWith({
    String? id,
    String? personName,
    double? amount,
    IouType? type,
    DateTime? date,
    String? note,
    bool? isSettled,
  }) {
    return Iou(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  @override
  List<Object?> get props =>
      [id, personName, amount, type, date, note, isSettled];
}