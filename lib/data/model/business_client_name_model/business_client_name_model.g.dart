// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_client_name_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessClientNameModel _$BusinessClientNameModelFromJson(
  Map<String, dynamic> json,
) => BusinessClientNameModel(
  success: json['success'] as bool?,
  currentPage: (json['current_page'] as num?)?.toInt(),
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => BusinessClientName.fromJson(e as Map<String, dynamic>))
          .toList(),
  total: (json['total'] as num?)?.toInt(),
  lastPage: (json['last_page'] as num?)?.toInt(),
  perPage: (json['per_page'] as num?)?.toInt(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$BusinessClientNameModelToJson(
  BusinessClientNameModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'current_page': instance.currentPage,
  'data': instance.data,
  'total': instance.total,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'message': instance.message,
};

BusinessClientName _$BusinessClientNameFromJson(Map<String, dynamic> json) =>
    BusinessClientName(
      id: (json['id'] as num?)?.toInt(),
      clientName: json['client_name'] as String?,
    );

Map<String, dynamic> _$BusinessClientNameToJson(BusinessClientName instance) =>
    <String, dynamic>{'id': instance.id, 'client_name': instance.clientName};
