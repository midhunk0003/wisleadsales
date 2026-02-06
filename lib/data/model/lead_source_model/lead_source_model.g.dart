// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_source_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeadSourceModel _$LeadSourceModelFromJson(Map<String, dynamic> json) =>
    LeadSourceModel(
      success: json['success'] as bool?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LeadSourceList.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$LeadSourceModelToJson(LeadSourceModel instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

LeadSourceList _$LeadSourceListFromJson(Map<String, dynamic> json) =>
    LeadSourceList(
      id: (json['id'] as num?)?.toInt(),
      source: json['source'] as String?,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );

Map<String, dynamic> _$LeadSourceListToJson(LeadSourceList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
