// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facial_metrics_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FacialMetricsHiveAdapter extends TypeAdapter<FacialMetricsHive> {
  @override
  final int typeId = 0;

  @override
  FacialMetricsHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FacialMetricsHive(
      bizygomaticWidth: fields[0] as double,
      intercanthalDistance: fields[1] as double,
      timestamp: fields[2] as DateTime,
      id: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FacialMetricsHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bizygomaticWidth)
      ..writeByte(1)
      ..write(obj.intercanthalDistance)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacialMetricsHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
