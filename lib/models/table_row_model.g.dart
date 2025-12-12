// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_row_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TableRowDataAdapter extends TypeAdapter<TableRowData> {
  @override
  final int typeId = 1;

  @override
  TableRowData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TableRowData(
      date: fields[0] as DateTime?,
      day: fields[1] as String?,
      classSubjects: (fields[2] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as List).cast<String>())),
    );
  }

  @override
  void write(BinaryWriter writer, TableRowData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.day)
      ..writeByte(2)
      ..write(obj.classSubjects);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableRowDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
