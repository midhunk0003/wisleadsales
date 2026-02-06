import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/notification_model/notification_model.dart';
import 'package:wisdeals/domain/repository/notification_repository.dart';

class NotificationRepositoryImplimentation implements NotificationRepository {
  @override
  Future<Either<Failure, List<NotificationList>>> getNotification(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.notificationsEndPoint}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log("Notification response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List allNotification = decoded['data'] ?? [];

        final notifications =
            allNotification.map((e) => NotificationList.fromJson(e)).toList();
        print('inside impli ${notifications}');
        return Right(notifications);
      }
      // ✅ 401 — TOKEN EXPIRED / UNAUTHORIZED
      if (response.statusCode == 401) {
        String message = "Unauthorized access";

        final errorBody = json.decode(response.body);

        message = errorBody['message'] ?? message;

        return Left(AuthFailure(message));
      }
      // 🔴 Client errors (400–499)
      if (response.statusCode >= 400 && response.statusCode < 500) {
        final decoded = json.decode(response.body);
        final message = decoded['message'] ?? 'Client error';
        return Left(ClientFailure(message));
      }

      // 🔴 Server errors (500+)
      if (response.statusCode >= 500) {
        return Left(ServerFailure('Internal server error'));
      }

      return Left(
        OtherFailureNon200('Unexpected status: ${response.statusCode}'),
      );
    }
    // 🌐 No internet
    on SocketException {
      return Left(NetworkFailure('No Internet connection'));
    }
    // ❌ Any other error
    catch (e) {
      log('Unexpected error: $e');
      return Left(OtherFailureNon200('Unexpected error occurred'));
    } finally {
      client.close();
    }
  }

  @override
  Future<Either<Failure, Success>> readNotification(
    String? token,
    String? notificationId,
  ) async {
    final client = http.Client();
    try {
      print('read notification go to .......');
      print('read notification go ${notificationId} .......');
      final response = await client.post(
        Uri.parse(
          '${ApiEndPoint.baseUrl}${ApiEndPoint.notificationsReadEndPoint}',
        ),
        headers: {'Authorization': 'Bearer $token'},
        body: {"id": notificationId ?? ''},
      );

      log('read notification: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside read notification: ${message}');
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
}
