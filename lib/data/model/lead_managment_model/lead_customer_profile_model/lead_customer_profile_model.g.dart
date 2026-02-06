// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_customer_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeadCustomerProfileModel _$LeadCustomerProfileModelFromJson(
  Map<String, dynamic> json,
) => LeadCustomerProfileModel(
  success: json['success'] as bool?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => CustomerProfileList.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$LeadCustomerProfileModelToJson(
  LeadCustomerProfileModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

CustomerProfileList _$CustomerProfileListFromJson(Map<String, dynamic> json) =>
    CustomerProfileList(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );

Map<String, dynamic> _$CustomerProfileListToJson(
  CustomerProfileList instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
