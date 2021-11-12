// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disease.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiseaseAdapter extends TypeAdapter<Disease> {
  @override
  final int typeId = 2;

  @override
  Disease read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Disease(
      diseaseID: fields[0] as String,
      diseaseNameEN: fields[1] as String,
      diseaseNameHI: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Disease obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.diseaseID)
      ..writeByte(1)
      ..write(obj.diseaseNameEN)
      ..writeByte(2)
      ..write(obj.diseaseNameHI);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiseaseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
