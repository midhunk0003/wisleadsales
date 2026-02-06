import 'package:json_annotation/json_annotation.dart';

part 'leave_attendance_model.g.dart';

String? _stringFromDynamic(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class LeaveAttendanceModel {
  bool? success;
  DataLeaveAttendanceModelData? data;

  LeaveAttendanceModel({this.success, this.data});

  factory LeaveAttendanceModel.fromJson(Map<String, dynamic> json) {
    return _$LeaveAttendanceModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeaveAttendanceModelToJson(this);
}

@JsonSerializable()
class DataLeaveAttendanceModelData {
  @JsonKey(name: 'attendance_date', fromJson: _stringFromDynamic)
  String? attendanceDate;
  @JsonKey(name: 'clock_in', fromJson: _stringFromDynamic)
  String? clockIn;
  @JsonKey(name: 'clock_out', fromJson: _stringFromDynamic)
  String? clockOut;
  @JsonKey(name: 'total_hours', fromJson: _stringFromDynamic)
  String? totalHours;
  @JsonKey(name: 'has_clocked_in')
  bool? hasClockedIn;
  @JsonKey(name: 'has_clocked_out')
  bool? hasClockedOut;
  @JsonKey(name: 'leave_balance', fromJson: _stringFromDynamic)
  String? leaveBalance;
  @JsonKey(name: 'total_allowance', fromJson: _stringFromDynamic)
  String? totalAllowance;
  @JsonKey(name: 'used_days', fromJson: _stringFromDynamic)
  String? usedDays;
  @JsonKey(name: 'leave_approved', fromJson: _stringFromDynamic)
  String? leaveApproved;
  @JsonKey(name: 'leave_pending', fromJson: _stringFromDynamic)
  String? leavePending;
  @JsonKey(name: 'leave_cancelled', fromJson: _stringFromDynamic)
  String? leaveCancelled;
  @JsonKey(name: 'leave_history')
  List<LeaveHistory>? leaveHistory;

  DataLeaveAttendanceModelData({
    this.attendanceDate,
    this.clockIn,
    this.clockOut,
    this.totalHours,
    this.hasClockedIn,
    this.hasClockedOut,
    this.leaveBalance,
    this.totalAllowance,
    this.usedDays,
    this.leaveApproved,
    this.leavePending,
    this.leaveCancelled,
    this.leaveHistory,
  });

  factory DataLeaveAttendanceModelData.fromJson(Map<String, dynamic> json) =>
      _$DataLeaveAttendanceModelDataFromJson(json);

  Map<String, dynamic> toJson() => _$DataLeaveAttendanceModelDataToJson(this);
}

@JsonSerializable()
class LeaveHistory {
  int? id;
  @JsonKey(name: 'user_id', fromJson: _stringFromDynamic)
  String? userId;
  @JsonKey(name: 'leave_type_id', fromJson: _stringFromDynamic)
  String? leaveTypeId;
  @JsonKey(name: 'leave_type', fromJson: _stringFromDynamic)
  String? leaveType;
  @JsonKey(name: 'from_date', fromJson: _stringFromDynamic)
  String? fromDate;
  @JsonKey(name: 'to_date', fromJson: _stringFromDynamic)
  String? toDate;
  String? reason;
  dynamic attachment;
  String? status;
  @JsonKey(name: 'admin_comment', fromJson: _stringFromDynamic)
  String? adminComment;
  @JsonKey(name: 'created_at', fromJson: _stringFromDynamic)
  String? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _stringFromDynamic)
  String? updatedAt;
  @JsonKey(name: 'deleted_at', fromJson: _stringFromDynamic)
  String? deletedAt;

  LeaveHistory({
    this.id,
    this.userId,
    this.leaveTypeId,
    this.leaveType,
    this.fromDate,
    this.toDate,
    this.reason,
    this.attachment,
    this.status,
    this.adminComment,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory LeaveHistory.fromJson(Map<String, dynamic> json) {
    return _$LeaveHistoryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeaveHistoryToJson(this);
}
