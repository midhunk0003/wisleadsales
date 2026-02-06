// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
  success: json['success'] as bool?,
  userId: json['user_id'] as String?,
  range:
      json['range'] == null
          ? null
          : Range.fromJson(json['range'] as Map<String, dynamic>),
  report:
      json['report'] == null
          ? null
          : Report.fromJson(json['report'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'user_id': instance.userId,
      'range': instance.range,
      'report': instance.report,
    };

Range _$RangeFromJson(Map<String, dynamic> json) =>
    Range(start: json['start'] as String?, end: json['end'] as String?);

Map<String, dynamic> _$RangeToJson(Range instance) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
};

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
  title: json['title'] as String?,
  totalClients: json['total_clients'] as String?,
  activeClients: json['active_clients'] as String?,
  activeClientsPercentage: json['active_clients_percentage'] as String?,
  inactiveClients: json['inactive_clients'] as String?,
  inactiveClientsPercentage: json['inactive_clients_percentage'] as String?,
  pendingClients: json['pending_clients'] as String?,
  pendingClientsPercentage: json['pending_clients_percentage'] as String?,
  newClients: json['new_clients'] as String?,
  newClientsPercentage: json['new_clients_percentage'] as String?,
  totalExpenses: json['total_expenses'] as String?,
  expenseCount: json['expense_count'] as String?,
  pendingAmount: json['pending_amount'] as String?,
  pendingCount: json['pending_count'] as String?,
  pendingPercentageAmount: json['pending_percentage_amount'] as String?,
  pendingPercentageCount: json['pending_percentage_count'] as String?,
  approvedAmount: json['approved_amount'] as String?,
  approvedCount: json['approved_count'] as String?,
  approvedPercentageAmount: json['approved_percentage_amount'] as String?,
  approvedPercentageCount: json['approved_percentage_count'] as String?,
  rejectedAmount: json['rejected_amount'] as String?,
  rejectedCount: json['rejected_count'] as String?,
  rejectedPercentageAmount: json['rejected_percentage_amount'] as String?,
  rejectedPercentageCount: json['rejected_percentage_count'] as String?,
  totalLeads: json['total_leads'] as String?,
  convertedLeads: json['converted_leads'] as String?,
  pendingLeads: json['pending_leads'] as String?,
  convertedPercentage: json['converted_percentage'] as String?,
  pendingPercentage: json['pending_percentage'] as String?,
  totalDays: json['total_days'] as String?,
  presentDays: json['present_days'] as String?,
  presentPercentage: json['present_percentage'] as String?,
  absentDays: json['absent_days'] as String?,
  absentPercentage: json['absent_percentage'] as String?,
  lateDays: json['late_days'] as String?,
  latePercentage: json['late_percentage'] as String?,
  earlyLogoutDays: json['early_logout_days'] as String?,
  earlyLogoutPercentage: json['early_logout_percentage'] as String?,
);

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
  'title': instance.title,
  'total_clients': instance.totalClients,
  'active_clients': instance.activeClients,
  'active_clients_percentage': instance.activeClientsPercentage,
  'inactive_clients': instance.inactiveClients,
  'inactive_clients_percentage': instance.inactiveClientsPercentage,
  'pending_clients': instance.pendingClients,
  'pending_clients_percentage': instance.pendingClientsPercentage,
  'new_clients': instance.newClients,
  'new_clients_percentage': instance.newClientsPercentage,
  'total_expenses': instance.totalExpenses,
  'expense_count': instance.expenseCount,
  'pending_amount': instance.pendingAmount,
  'pending_count': instance.pendingCount,
  'pending_percentage_amount': instance.pendingPercentageAmount,
  'pending_percentage_count': instance.pendingPercentageCount,
  'approved_amount': instance.approvedAmount,
  'approved_count': instance.approvedCount,
  'approved_percentage_amount': instance.approvedPercentageAmount,
  'approved_percentage_count': instance.approvedPercentageCount,
  'rejected_amount': instance.rejectedAmount,
  'rejected_count': instance.rejectedCount,
  'rejected_percentage_amount': instance.rejectedPercentageAmount,
  'rejected_percentage_count': instance.rejectedPercentageCount,
  'total_leads': instance.totalLeads,
  'converted_leads': instance.convertedLeads,
  'pending_leads': instance.pendingLeads,
  'converted_percentage': instance.convertedPercentage,
  'pending_percentage': instance.pendingPercentage,
  'total_days': instance.totalDays,
  'present_days': instance.presentDays,
  'present_percentage': instance.presentPercentage,
  'absent_days': instance.absentDays,
  'absent_percentage': instance.absentPercentage,
  'late_days': instance.lateDays,
  'late_percentage': instance.latePercentage,
  'early_logout_days': instance.earlyLogoutDays,
  'early_logout_percentage': instance.earlyLogoutPercentage,
};
