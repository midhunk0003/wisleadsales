// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_payment_mode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpensesPaymentModeModel _$ExpensesPaymentModeModelFromJson(
  Map<String, dynamic> json,
) => ExpensesPaymentModeModel(
  success: json['success'] as bool?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map(
            (e) => ExpensesPaymentModeList.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$ExpensesPaymentModeModelToJson(
  ExpensesPaymentModeModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

ExpensesPaymentModeList _$ExpensesPaymentModeListFromJson(
  Map<String, dynamic> json,
) => ExpensesPaymentModeList(
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

Map<String, dynamic> _$ExpensesPaymentModeListToJson(
  ExpensesPaymentModeList instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt,
};
