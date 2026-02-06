// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveTypeModel _$LeaveTypeModelFromJson(Map<String, dynamic> json) =>
    LeaveTypeModel(
      success: json['success'] as bool?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LeaveTypeData.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$LeaveTypeModelToJson(LeaveTypeModel instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

LeaveTypeData _$LeaveTypeDataFromJson(Map<String, dynamic> json) =>
    LeaveTypeData(
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

Map<String, dynamic> _$LeaveTypeDataToJson(LeaveTypeData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt,
    };
