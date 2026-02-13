// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_name_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessNameModel _$BusinessNameModelFromJson(Map<String, dynamic> json) =>
    BusinessNameModel(
      success: json['success'] as bool?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => BusinessName.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$BusinessNameModelToJson(BusinessNameModel instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

BusinessName _$BusinessNameFromJson(Map<String, dynamic> json) => BusinessName(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  status: json['status'] as bool?,
  createdAt: json['created_at'],
  updatedAt: json['updated_at'],
);

Map<String, dynamic> _$BusinessNameToJson(BusinessName instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
