// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expanse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpanseModel _$ExpanseModelFromJson(Map<String, dynamic> json) => ExpanseModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => ExpanseData.fromJson(e as Map<String, dynamic>))
          .toList(),
  pending: json['Pending'] as String?,
  approved: json['Approved'] as String?,
  rejected: json['Rejected'] as String?,
  total: json['total'] as String?,
);

Map<String, dynamic> _$ExpanseModelToJson(ExpanseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
      'Pending': instance.pending,
      'Approved': instance.approved,
      'Rejected': instance.rejected,
      'total': instance.total,
    };

ExpanseData _$ExpanseDataFromJson(Map<String, dynamic> json) => ExpanseData(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  clientName: json['client_name'] as String?,
  companyName: json['company_name'] as String?,
  expenseTypeId: (json['expense_type_id'] as num?)?.toInt(),
  expenseType: json['expense_type'] as String?,
  amount: json['amount'] as String?,
  paymentModeId: (json['payment_mode_id'] as num?)?.toInt(),
  paymentMode: json['payment_mode'] as String?,
  receipt: json['receipt'],
  notes: json['notes'] as String?,
  status: json['status'] as String?,
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

Map<String, dynamic> _$ExpanseDataToJson(ExpanseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'client_name': instance.clientName,
      'company_name': instance.companyName,
      'expense_type_id': instance.expenseTypeId,
      'expense_type': instance.expenseType,
      'amount': instance.amount,
      'payment_mode_id': instance.paymentModeId,
      'payment_mode': instance.paymentMode,
      'receipt': instance.receipt,
      'notes': instance.notes,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt,
    };
