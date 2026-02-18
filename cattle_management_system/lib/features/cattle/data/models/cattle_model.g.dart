// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cattle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CattleModel _$CattleModelFromJson(Map<String, dynamic> json) => CattleModel(
      id: json['id'] as String,
      tagNumber: json['tagNumber'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      color: json['color'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CattleModelToJson(CattleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tagNumber': instance.tagNumber,
      'name': instance.name,
      'breed': instance.breed,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'color': instance.color,
      'weight': instance.weight,
      'status': instance.status,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
