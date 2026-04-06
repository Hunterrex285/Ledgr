import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String categoryId;
  final double limit;
  final DateTime month; // store as first day of the month

  const Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
  });

  Budget copyWith({
    String? id,
    String? categoryId,
    double? limit,
    DateTime? month,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limit: limit ?? this.limit,
      month: month ?? this.month,
    );
  }

  @override
  List<Object?> get props => [id, categoryId, limit, month];
}