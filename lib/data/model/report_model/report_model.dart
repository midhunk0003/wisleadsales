import 'package:json_annotation/json_annotation.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel {
  bool? success;

  @JsonKey(name: 'user_id')
  String? userId;

  Range? range;
  Report? report;

  ReportModel({this.success, this.userId, this.range, this.report});

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);
}

@JsonSerializable()
class Range {
  String? start;
  String? end;

  Range({this.start, this.end});

  factory Range.fromJson(Map<String, dynamic> json) => _$RangeFromJson(json);

  Map<String, dynamic> toJson() => _$RangeToJson(this);
}

@JsonSerializable()
class Report {
  // Common
  String? title;

  // -------- CLIENT REPORT --------
  @JsonKey(name: 'total_clients')
  String? totalClients;

  @JsonKey(name: 'active_clients')
  String? activeClients;

  @JsonKey(name: 'active_clients_percentage')
  String? activeClientsPercentage;

  @JsonKey(name: 'inactive_clients')
  String? inactiveClients;

  @JsonKey(name: 'inactive_clients_percentage')
  String? inactiveClientsPercentage;

  @JsonKey(name: 'pending_clients')
  String? pendingClients;

  @JsonKey(name: 'pending_clients_percentage')
  String? pendingClientsPercentage;

  @JsonKey(name: 'new_clients')
  String? newClients;

  @JsonKey(name: 'new_clients_percentage')
  String? newClientsPercentage;

  // -------- EXPENSE REPORT --------
  @JsonKey(name: 'total_expenses')
  String? totalExpenses;

  @JsonKey(name: 'expense_count')
  String? expenseCount;

  @JsonKey(name: 'pending_amount')
  String? pendingAmount;

  @JsonKey(name: 'pending_count')
  String? pendingCount;

  @JsonKey(name: 'pending_percentage_amount')
  String? pendingPercentageAmount;

  @JsonKey(name: 'pending_percentage_count')
  String? pendingPercentageCount;

  @JsonKey(name: 'approved_amount')
  String? approvedAmount;

  @JsonKey(name: 'approved_count')
  String? approvedCount;

  @JsonKey(name: 'approved_percentage_amount')
  String? approvedPercentageAmount;

  @JsonKey(name: 'approved_percentage_count')
  String? approvedPercentageCount;

  @JsonKey(name: 'rejected_amount')
  String? rejectedAmount;

  @JsonKey(name: 'rejected_count')
  String? rejectedCount;

  @JsonKey(name: 'rejected_percentage_amount')
  String? rejectedPercentageAmount;

  @JsonKey(name: 'rejected_percentage_count')
  String? rejectedPercentageCount;

  // -------- LEAD REPORT --------
  @JsonKey(name: 'total_leads')
  String? totalLeads;

  @JsonKey(name: 'converted_leads')
  String? convertedLeads;

  @JsonKey(name: 'pending_leads')
  String? pendingLeads;

  @JsonKey(name: 'converted_percentage')
  String? convertedPercentage;

  @JsonKey(name: 'pending_percentage')
  String? pendingPercentage;

  // -------- ATTENDANCE REPORT --------
  @JsonKey(name: 'total_days')
  String? totalDays;

  @JsonKey(name: 'present_days')
  String? presentDays;

  @JsonKey(name: 'present_percentage')
  String? presentPercentage;

  @JsonKey(name: 'absent_days')
  String? absentDays;

  @JsonKey(name: 'absent_percentage')
  String? absentPercentage;

  @JsonKey(name: 'late_days')
  String? lateDays;

  @JsonKey(name: 'late_percentage')
  String? latePercentage;

  @JsonKey(name: 'early_logout_days')
  String? earlyLogoutDays;

  @JsonKey(name: 'early_logout_percentage')
  String? earlyLogoutPercentage;

  Report({
    this.title,
    // client
    this.totalClients,
    this.activeClients,
    this.activeClientsPercentage,
    this.inactiveClients,
    this.inactiveClientsPercentage,
    this.pendingClients,
    this.pendingClientsPercentage,
    this.newClients,
    this.newClientsPercentage,
    // expense
    this.totalExpenses,
    this.expenseCount,
    this.pendingAmount,
    this.pendingCount,
    this.pendingPercentageAmount,
    this.pendingPercentageCount,
    this.approvedAmount,
    this.approvedCount,
    this.approvedPercentageAmount,
    this.approvedPercentageCount,
    this.rejectedAmount,
    this.rejectedCount,
    this.rejectedPercentageAmount,
    this.rejectedPercentageCount,
    // leads
    this.totalLeads,
    this.convertedLeads,
    this.pendingLeads,
    this.convertedPercentage,
    this.pendingPercentage,
    // attendance
    this.totalDays,
    this.presentDays,
    this.presentPercentage,
    this.absentDays,
    this.absentPercentage,
    this.lateDays,
    this.latePercentage,
    this.earlyLogoutDays,
    this.earlyLogoutPercentage,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
