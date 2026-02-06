// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeadStatusModel _$LeadStatusModelFromJson(Map<String, dynamic> json) =>
    LeadStatusModel(
      success: json['success'] as bool?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LeadStatus.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$LeadStatusModelToJson(LeadStatusModel instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

LeadStatus _$LeadStatusFromJson(Map<String, dynamic> json) => LeadStatus(
  id: (json['id'] as num?)?.toInt(),
  status: json['status'] as String?,
  leadCount: json['lead_count'],
);

Map<String, dynamic> _$LeadStatusToJson(LeadStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'lead_count': instance.leadCount,
    };
