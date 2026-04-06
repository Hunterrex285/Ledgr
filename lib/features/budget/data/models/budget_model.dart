import 'package:hive/hive.dart';
import 'package:ledgr/features/budget/domain/entites/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 1)
class BudgetModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String categoryId;
  @HiveField(2) final double limit;
  @HiveField(3) final DateTime month;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
  });

  Budget toEntity() => Budget(
    id: id,
    categoryId: categoryId,
    limit: limit,
    month: month,
  );

  factory BudgetModel.fromEntity(Budget b) => BudgetModel(
    id: b.id,
    categoryId: b.categoryId,
    limit: b.limit,
    month: b.month,
  );
}