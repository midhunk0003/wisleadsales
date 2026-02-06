import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/app_update_version.dart/app_update_version_repository.dart';
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/app_update_version_model/app_update_version_model.dart';

class AppUpdateVersionnRepositoryImpli implements AppUpdateVersionRepository {
  @override
  Future<Either<Failure, AppUpdateVersionModel>> getAppUpdateVersion(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.versionEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      log(
        '**********************get app update version response **************** : ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final leaveData = AppUpdateVersionModel.fromJson(data);
        print(' app update version response: ${leaveData}');
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
      log('Unexpected error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }
}
