// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanResultHiveAdapter extends TypeAdapter<ScanResultHive> {
  @override
  final int typeId = 1;

  @override
  ScanResultHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResultHive(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      frontImagePath: fields[2] as String,
      sideImagePath: fields[3] as String?,
      metrics: (fields[4] as Map).cast<String, dynamic>(),
      meshPointsCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResultHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.frontImagePath)
      ..writeByte(3)
      ..write(obj.sideImagePath)
      ..writeByte(4)
      ..write(obj.metrics)
      ..writeByte(5)
      ..write(obj.meshPointsCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
