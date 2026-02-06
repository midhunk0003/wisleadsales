import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/profile_model/profile_model.dart';
import 'package:wisdeals/domain/repository/profile_repository.dart';

class ProfileRepositoryImpli implements ProfileRepository {
  @override
  Future<Either<Failure, ProfileData>> getProfile(String? token) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.profileEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
      );
      log("get profile data   : ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final profileData = ProfileData.fromJson(data);
        print('profile data  inside : ${profileData.id}');
        return Right(profileData);
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

  @override
  Future<Either<Failure, Success>> uploadProfileVerification(
    String? token,
    String? userId,
    String? photo,
    String? resumeFile,
    String? addressDocFile,
    String? accNumber,
    String? accName,
    String? ifscCode,
  ) async {
    final client = http.Client();

    try {
      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.updateProfile}',
      );
      print('go add profile verify  .......');
      print('photo1 : ${photo}.......');
      print('photo2 : ${resumeFile}.......');
      print('photo3 : ${addressDocFile}.......');
      final request = http.MultipartRequest('POST', uri);
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      // Add form fields
      request.fields['id'] = userId ?? '';
      request.fields['bank_name'] = accName ?? '';
      request.fields['bank_account_no'] = accNumber ?? '';
      request.fields['ifsc_code'] = ifscCode ?? '';

      if (photo != null) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx ${photo}');
        final cleanedPath = photo
            .toString()
            .replaceAll("File: '", "")
            .replaceAll("'", "");
        print('Cleaned path: $cleanedPath');
        final fileImage = File(cleanedPath);
        print('exit is there0 : ${await fileImage.path}');

        if (await fileImage.exists()) {
          final imageBytes = await fileImage.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'profile_image',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      if (resumeFile != null) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx ${resumeFile}');
        final cleanedPath = resumeFile
            .toString()
            .replaceAll("File: '", "")
            .replaceAll("'", "");
        print('Cleaned path: $cleanedPath');
        final fileImage = File(cleanedPath);
        print('exit is there1 : ${await fileImage.path}');

        if (await fileImage.exists()) {
          final imageBytes = await fileImage.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'resume',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      if (addressDocFile != null) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx ${addressDocFile}');
        final cleanedPath = addressDocFile
            .toString()
            .replaceAll("File: '", "")
            .replaceAll("'", "");
        print('Cleaned path: $cleanedPath');
        final fileImage = File(cleanedPath);
        print('exit is there2 : ${await fileImage.path}');

        if (await fileImage.exists()) {
          final imageBytes = await fileImage.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'address_proof',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('response add profile: ${response.statusCode}');
      log('response body profile add: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside profile add  : ${message}');
        return Right(Success(message: message));
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
