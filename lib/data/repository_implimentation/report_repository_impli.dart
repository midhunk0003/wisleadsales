import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/report_model/report_model.dart';
import 'package:wisdeals/domain/repository/report_repository.dart';

class ReportRepositoryImpli implements ReportRepository {
  @override
  Future<Either<Failure, ReportModel>> getReport(
    String? token,
    String? type,
    String? range,
    String? startDate,
    String? endDate,
  ) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.reportsEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'type': type ?? '',
          'range': range ?? '',
          'start_date': startDate ?? '',
          'end_date': endDate ?? '',
        },
      );

      log("Report Data  : ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final clientsList = ReportModel.fromJson(data);
        print('Report Data inside : ${clientsList}');
        return Right(clientsList);
      }
      // ✅ 401 — TOKEN EXPIRED / UNAUTHORIZED
      else if (response.statusCode == 401) {
        String message = "Unauthorized access";

        final errorBody = json.decode(response.body);

        message = errorBody['message'] ?? message;

        return Left(AuthFailure(message));
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
