// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_target_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyTargetModel _$MonthlyTargetModelFromJson(Map<String, dynamic> json) =>
    MonthlyTargetModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data:
          json['data'] == null
              ? null
              : ProjectMonthData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MonthlyTargetModelToJson(MonthlyTargetModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ProjectMonthData _$ProjectMonthDataFromJson(Map<String, dynamic> json) =>
    ProjectMonthData(
      userId: (json['user_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      year: (json['year'] as num?)?.toInt(),
      targets:
          (json['targets'] as List<dynamic>?)
              ?.map((e) => Target.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$ProjectMonthDataToJson(ProjectMonthData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'name': instance.name,
      'year': instance.year,
      'targets': instance.targets,
    };

Target _$TargetFromJson(Map<String, dynamic> json) => Target(
  month: json['month'] as String?,
  monthNumber: (json['month_number'] as num?)?.toInt(),
  targetAmount: (json['target_amount'] as num?)?.toInt(),
  achievedAmount: (json['achieved_amount'] as num?)?.toInt(),
  pendingAmount: (json['pending_amount'] as num?)?.toInt(),
  percentage: (json['percentage'] as num?)?.toInt(),
  status: json['status'] as String?,
);

Map<String, dynamic> _$TargetToJson(Target instance) => <String, dynamic>{
  'month': instance.month,
  'month_number': instance.monthNumber,
  'target_amount': instance.targetAmount,
  'achieved_amount': instance.achievedAmount,
  'pending_amount': instance.pendingAmount,
  'percentage': instance.percentage,
  'status': instance.status,
};
