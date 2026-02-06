import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/leave_attendance_model/leave_attendance_model.dart';
import 'package:wisdeals/data/model/leave_type_model/leave_type_model.dart';

abstract class AttendanceAndLeaveRepository {
  Future<Either<Failure, Success>> addLeave(
    String? token,
    String? leaveTypeId,
    String? datefrom,
    String? dateTo,
    String? reason,
    String? file,
  );

  Future<Either<Failure, Success>> updateLeave(
    String? token,
    String? id,
    String? leaveType,
    String? datefrom,
    String? dateTo,
    String? reason,
    String? file,
  );
  Future<Either<Failure, LeaveAttendanceModel>> getLeaveAndAttendance(
    String? token,
    String? date,
  );
  Future<Either<Failure, Success>> deleteLeave(String? token, String? leaveId);

  Future<Either<Failure, List<LeaveTypeData>>> getLeaveTypes(String? token);
}
