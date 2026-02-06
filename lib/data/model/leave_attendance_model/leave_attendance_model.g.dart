// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveAttendanceModel _$LeaveAttendanceModelFromJson(
  Map<String, dynamic> json,
) => LeaveAttendanceModel(
  success: json['success'] as bool?,
  data:
      json['data'] == null
          ? null
          : DataLeaveAttendanceModelData.fromJson(
            json['data'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$LeaveAttendanceModelToJson(
  LeaveAttendanceModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

DataLeaveAttendanceModelData _$DataLeaveAttendanceModelDataFromJson(
  Map<String, dynamic> json,
) => DataLeaveAttendanceModelData(
  attendanceDate: _stringFromDynamic(json['attendance_date']),
  clockIn: _stringFromDynamic(json['clock_in']),
  clockOut: _stringFromDynamic(json['clock_out']),
  totalHours: _stringFromDynamic(json['total_hours']),
  hasClockedIn: json['has_clocked_in'] as bool?,
  hasClockedOut: json['has_clocked_out'] as bool?,
  leaveBalance: _stringFromDynamic(json['leave_balance']),
  totalAllowance: _stringFromDynamic(json['total_allowance']),
  usedDays: _stringFromDynamic(json['used_days']),
  leaveApproved: _stringFromDynamic(json['leave_approved']),
  leavePending: _stringFromDynamic(json['leave_pending']),
  leaveCancelled: _stringFromDynamic(json['leave_cancelled']),
  leaveHistory:
      (json['leave_history'] as List<dynamic>?)
          ?.map((e) => LeaveHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$DataLeaveAttendanceModelDataToJson(
  DataLeaveAttendanceModelData instance,
) => <String, dynamic>{
  'attendance_date': instance.attendanceDate,
  'clock_in': instance.clockIn,
  'clock_out': instance.clockOut,
  'total_hours': instance.totalHours,
  'has_clocked_in': instance.hasClockedIn,
  'has_clocked_out': instance.hasClockedOut,
  'leave_balance': instance.leaveBalance,
  'total_allowance': instance.totalAllowance,
  'used_days': instance.usedDays,
  'leave_approved': instance.leaveApproved,
  'leave_pending': instance.leavePending,
  'leave_cancelled': instance.leaveCancelled,
  'leave_history': instance.leaveHistory,
};

LeaveHistory _$LeaveHistoryFromJson(Map<String, dynamic> json) => LeaveHistory(
  id: (json['id'] as num?)?.toInt(),
  userId: _stringFromDynamic(json['user_id']),
  leaveTypeId: _stringFromDynamic(json['leave_type_id']),
  leaveType: _stringFromDynamic(json['leave_type']),
  fromDate: _stringFromDynamic(json['from_date']),
  toDate: _stringFromDynamic(json['to_date']),
  reason: json['reason'] as String?,
  attachment: json['attachment'],
  status: json['status'] as String?,
  adminComment: _stringFromDynamic(json['admin_comment']),
  createdAt: _stringFromDynamic(json['created_at']),
  updatedAt: _stringFromDynamic(json['updated_at']),
  deletedAt: _stringFromDynamic(json['deleted_at']),
);

Map<String, dynamic> _$LeaveHistoryToJson(LeaveHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'leave_type_id': instance.leaveTypeId,
      'leave_type': instance.leaveType,
      'from_date': instance.fromDate,
      'to_date': instance.toDate,
      'reason': instance.reason,
      'attachment': instance.attachment,
      'status': instance.status,
      'admin_comment': instance.adminComment,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
