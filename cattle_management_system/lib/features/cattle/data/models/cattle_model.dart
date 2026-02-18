import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cattle.dart';

part 'cattle_model.g.dart';

/// Cattle Model (Data Layer)
@JsonSerializable()
class CattleModel extends Cattle {
  const CattleModel({
    required super.id,
    required super.tagNumber,
    required super.name,
    required super.breed,
    required super.gender,
    required super.dateOfBirth,
    super.color,
    super.weight,
    required super.status,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });
  
  factory CattleModel.fromJson(Map<String, dynamic> json) =>
      _$CattleModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CattleModelToJson(this);
  
  factory CattleModel.fromEntity(Cattle cattle) {
    return CattleModel(
      id: cattle.id,
      tagNumber: cattle.tagNumber,
      name: cattle.name,
      breed: cattle.breed,
      gender: cattle.gender,
      dateOfBirth: cattle.dateOfBirth,
      color: cattle.color,
      weight: cattle.weight,
      status: cattle.status,
      imageUrl: cattle.imageUrl,
      createdAt: cattle.createdAt,
      updatedAt: cattle.updatedAt,
    );
  }
}
