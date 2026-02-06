import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/login_model/login_model.dart';
import 'package:wisdeals/domain/repository/auth_repository.dart';

class AuthRepositoryImplimentation implements AuthRepository {
  @override
  Future<Either<Failure, LoginModel>> login(
    String? email,
    String? password,
    String? fcmToken,
  ) async {
    final client = http.Client();
    print(
      "LoginRepositoryImplimentation login called with: $email, $password, $fcmToken",
    );
    try {
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.loginEndPoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email!.trim(),
          'password': password!.trim(),
          'fcm_token': fcmToken ?? '',
        }),
      );
      log(' Login response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'] ?? '';
        final profileImage = data['profileImage'] ?? '';
        final userJson = data['user'] ?? '';

        // save data to shared pref
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('profileImage', profileImage);
        // user part
        await prefs.setString('name', userJson['name'] ?? '');
        await prefs.setString('email', userJson['email'] ?? '');
        await prefs.setString('phone', userJson['phone'] ?? '');
        await prefs.setString('role', userJson['role'] ?? '');
        final loginUserDetails = LoginModel.fromJson(data);
        return Right(loginUserDetails);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Invalid credentials';
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
      log('Unexpected errorssss: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    }
  }
}
