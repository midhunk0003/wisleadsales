// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_travel_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseTravelTypeModel _$ExpenseTravelTypeModelFromJson(
  Map<String, dynamic> json,
) => ExpenseTravelTypeModel(
  success: json['success'] as bool?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ExpenseTravelData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ExpenseTravelTypeModelToJson(
  ExpenseTravelTypeModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

ExpenseTravelData _$ExpenseTravelDataFromJson(Map<String, dynamic> json) =>
    ExpenseTravelData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
    );

Map<String, dynamic> _$ExpenseTravelDataToJson(ExpenseTravelData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt,
    };
