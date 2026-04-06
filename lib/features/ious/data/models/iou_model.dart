import 'package:hive/hive.dart';
import '../../domain/entities/iou.dart';

part 'iou_model.g.dart';

@HiveType(typeId: 2)
class IouModel extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String personName;
  @HiveField(2) final double amount;
  @HiveField(3) final int typeIndex; // 0 = lent, 1 = borrowed
  @HiveField(4) final DateTime date;
  @HiveField(5) final String? note;
  @HiveField(6) final bool isSettled;

  IouModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.typeIndex,
    required this.date,
    this.note,
    this.isSettled = false,
  });

  Iou toEntity() => Iou(
        id: id,
        personName: personName,
        amount: amount,
        type: IouType.values[typeIndex],
        date: date,
        note: note,
        isSettled: isSettled,
      );

  factory IouModel.fromEntity(Iou iou) => IouModel(
        id: iou.id,
        personName: iou.personName,
        amount: iou.amount,
        typeIndex: iou.type.index,
        date: iou.date,
        note: iou.note,
        isSettled: iou.isSettled,
      );
}