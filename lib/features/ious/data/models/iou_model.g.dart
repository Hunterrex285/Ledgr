// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iou_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IouModelAdapter extends TypeAdapter<IouModel> {
  @override
  final int typeId = 2;

  @override
  IouModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IouModel(
      id: fields[0] as String,
      personName: fields[1] as String,
      amount: fields[2] as double,
      typeIndex: fields[3] as int,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
      isSettled: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, IouModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.typeIndex)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.isSettled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IouModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
