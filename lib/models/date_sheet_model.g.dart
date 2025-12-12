// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_sheet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DateSheetDataAdapter extends TypeAdapter<DateSheetData> {
  @override
  final int typeId = 0;

  @override
  DateSheetData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DateSheetData(
      schoolName: fields[0] as String,
      dateSheetDescription: fields[1] as String,
      termDescription: fields[2] as String,
      tableRows: (fields[3] as List?)?.cast<TableRowData>(),
      fileName: fields[4] as String,
      createdAt: fields[5] as DateTime?,
      classNames: (fields[6] as List?)?.cast<String>(),
      logoPath: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DateSheetData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.schoolName)
      ..writeByte(1)
      ..write(obj.dateSheetDescription)
      ..writeByte(2)
      ..write(obj.termDescription)
      ..writeByte(3)
      ..write(obj.tableRows)
      ..writeByte(4)
      ..write(obj.fileName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.classNames)
      ..writeByte(7)
      ..write(obj.logoPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateSheetDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
