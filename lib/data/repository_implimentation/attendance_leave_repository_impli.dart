import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/leave_attendance_model/leave_attendance_model.dart';
import 'package:wisdeals/data/model/leave_type_model/leave_type_model.dart';
import 'package:wisdeals/domain/repository/attendance_and_leave_repository.dart';

class AttendanceLeaveRepositoryImpli implements AttendanceAndLeaveRepository {
  @override
  Future<Either<Failure, Success>> addLeave(
    String? token,
    String? leaveTypeId,
    String? datefrom,
    String? dateTo,
    String? reason,
    String? file,
  ) async {
    final client = http.Client();

    try {
      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.leaveApplyEndPoint}',
      );
      print('go applay leave type id  ....... ${leaveTypeId}');
      final request = http.MultipartRequest('POST', uri);
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      // Add form fields
      request.fields['leave_type_id'] = leaveTypeId ?? '';
      request.fields['from_date'] = datefrom ?? '';
      request.fields['to_date'] = dateTo ?? '';
      request.fields['reason'] = reason ?? '';

      if (file != null) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx ${file}');
        final cleanedPath = file
            .toString()
            .replaceAll("File: '", "")
            .replaceAll("'", "");
        print('Cleaned path: $cleanedPath');
        final fileImage = File(cleanedPath);
        print('exit is there : ${await fileImage.path}');
        if (await fileImage.exists()) {
          final imageBytes = await fileImage.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'attachment',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('response add leave details  status: ${response.statusCode}');
      log('response body leave add: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside leave add  : ${message}');
        return Right(Success(message: message));
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Something went wrong';
        return Left(ClientFailure(message));
      } else if (response.statusCode >= 500) {
        try {
          final errorBody = json.decode(response.body);
          final message = errorBody['message'] ?? response.body.toString();
          return Left(ServerFailure(message));
        } catch (e) {
          print("XXXXXXXXXXXXX${e}");
          // if body is not JSON (HTML / plain text), just show raw body
          return Left(
            ServerFailure(
              response.body.isNotEmpty
                  ? 'Internal server error (500)'
                  : 'Internal server error (500)',
            ),
          );
        }
      } else {
        return Left(
          OtherFailureNon200('Unexpected status: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(NetworkFailure('No Internet connection'));
    } catch (e) {
      log('Unexpected error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }

  @override
  Future<Either<Failure, LeaveAttendanceModel>> getLeaveAndAttendance(
    String? token,
    String? date,
  ) async {
    // print('dates ${date}');
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.leaveListEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {"from_date": '$date'},
      );

      log('get leave based on date : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final leaveData = LeaveAttendanceModel.fromJson(data);
        print('inside leave data : ${leaveData}');
        return Right(leaveData);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Something went wrong';
        return Left(ClientFailure(message));
      } else if (response.statusCode >= 500) {
        try {
          final errorBody = json.decode(response.body);
          final message = errorBody['message'] ?? response.body.toString();
          return Left(ServerFailure(message));
        } catch (e) {
          print("XXXXXXXXXXXXX${e}");
          // if body is not JSON (HTML / plain text), just show raw body
          return Left(
            ServerFailure(
              response.body.isNotEmpty
                  ? 'Internal server error (500)'
                  : 'Internal server error (500)',
            ),
          );
        }
      } else {
        return Left(
          OtherFailureNon200('Unexpected status: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(NetworkFailure('No Internet connection'));
    } catch (e) {
      log('Unexpected error leave list: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }

  @override
  Future<Either<Failure, Success>> updateLeave(
    String? token,
    String? id,
    String? leaveType,
    String? datefrom,
    String? dateTo,
    String? reason,
    String? file,
  ) async {
    final client = http.Client();

    try {
      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.leaveUpdateEndPoint}',
      );
      print('go  edit leave  .......');
      final request = http.MultipartRequest('POST', uri);
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      // Add form fields
      request.fields['id'] = id ?? '';
      request.fields['leave_type_id'] = leaveType ?? '';
      request.fields['from_date'] = datefrom ?? '';
      request.fields['to_date'] = dateTo ?? '';
      request.fields['reason'] = reason ?? '';

      if (file != null) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx ${file}');
        final cleanedPath = file
            .toString()
            .replaceAll("File: '", "")
            .replaceAll("'", "");
        print('Cleaned path: $cleanedPath');
        final fileImage = File(cleanedPath);
        print('exit is there : ${await fileImage.path}');
        if (await fileImage.exists()) {
          final imageBytes = await fileImage.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'attachment',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('response add leave details  status: ${response.statusCode}');
      log('response body leave add: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside leave add  : ${message}');
        return Right(Success(message: message));
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Something went wrong';
        return Left(ClientFailure(message));
      } else if (response.statusCode >= 500) {
        try {
          final errorBody = json.decode(response.body);
          final message = errorBody['message'] ?? response.body.toString();
          return Left(ServerFailure(message));
        } catch (e) {
          print("XXXXXXXXXXXXX${e}");
          // if body is not JSON (HTML / plain text), just show raw body
          return Left(
            ServerFailure(
              response.body.isNotEmpty
                  ? 'Internal server error (500)'
                  : 'Internal server error (500)',
            ),
          );
        }
      } else {
        return Left(
          OtherFailureNon200('Unexpected status: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(NetworkFailure('No Internet connection'));
    } catch (e) {
      log('Unexpected error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }

  @override
  Future<Either<Failure, Success>> deleteLeave(
    String? token,
    String? leaveId,
  ) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.leaveDeleteEndPoint}/$leaveId",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("leave delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('leave delete inside : ${data['message']}');
        return Right(Success(message: data['message']));
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Something went wrong';
        return Left(ClientFailure(message));
      } else if (response.statusCode >= 500) {
        try {
          final errorBody = json.decode(response.body);
          final message = errorBody['message'] ?? response.body.toString();
          return Left(ServerFailure(message));
        } catch (e) {
          print("XXXXXXXXXXXXX${e}");
          // if body is not JSON (HTML / plain text), just show raw body
          return Left(
            ServerFailure(
              response.body.isNotEmpty
                  ? 'Internal server error (500)'
                  : 'Internal server error (500)',
            ),
          );
        }
      } else {
        return Left(
          OtherFailureNon200('Unexpected status: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(NetworkFailure('No Internet connection'));
    } catch (e) {
      log('Unexpected error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }

  @override
  Future<Either<Failure, List<LeaveTypeData>>> getLeaveTypes(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.leaveTypesEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      log('get leave Type : ${response.body}');

      if (response.statusCode == 200) {
        // final data = json.decode(response.body)['data'];
        // final leaveData = LeaveAttendanceModel.fromJson(data);
        final List<dynamic> data = json.decode(response.body)['data'];
        final leaveDataType =
            data.map((e) => LeaveTypeData.fromJson(e)).toList();
        print('get leave type : ${leaveDataType}');
        return Right(leaveDataType);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Something went wrong';
        return Left(ClientFailure(message));
      } else if (response.statusCode >= 500) {
        try {
          final errorBody = json.decode(response.body);
          final message = errorBody['message'] ?? response.body.toString();
          return Left(ServerFailure(message));
        } catch (e) {
          print("XXXXXXXXXXXXX${e}");
          // if body is not JSON (HTML / plain text), just show raw body
          return Left(
            ServerFailure(
              response.body.isNotEmpty
                  ? 'Internal server error (500)'
                  : 'Internal server error (500)',
            ),
          );
        }
      } else {
        return Left(
          OtherFailureNon200('Unexpected status: ${response.statusCode}'),
        );
      }
    } on SocketException {
      return Left(NetworkFailure('No Internet connection'));
    } catch (e) {
      log('Unexpected error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }
}
