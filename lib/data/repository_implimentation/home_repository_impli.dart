import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/home_model/home_model.dart';
import 'package:wisdeals/domain/repository/home_repository.dart';

class HomeRepositoryImpli implements HomeRepository {
  @override
  Future<Either<Failure, HomeDataModel>> getHomeData(String? token) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.getHomeEndPoint}"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        // body: {"status": status ?? ''},
      );
      log("get home data   : ${response.body}");
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body)['data'];
        final homeData = HomeDataModel.fromJson(jsonMap);
        print('get home data  inside : ${homeData}');
        return Right(homeData);
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
  Future<Either<Failure, Success>> clockIn(
    String? token,
    String? lat,
    String? long,
    String? km,
  ) async {
    final client = http.Client();
    try {
      print('go.......');
      print('lat.......${lat}');
      print('long.......${long}');
      print('km.......${km}');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.clockInEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {'latitude': lat, 'longitude': long},
      );

      log('ClockIn response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside clockin : ${message}');
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

  @override
  Future<Either<Failure, Success>> ClockOut(
    String? token,
    String? lat,
    String? long,
    String? km,
  ) async {
    final client = http.Client();
    try {
      print('go.......');
      print('lat out.......${lat}');
      print('long out.......${long}');
      print('km out.......${km}');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.clockOutEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {'latitude': lat, 'longitude': long, 'km': km},
      );

      log('ClockOut response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside ClockOut : ${message}');
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

  @override
  Future<Either<Failure, Success>> sendLatitudeAndLongitude(
    String? token,
    String? latitude,
    String? longitude,
  ) async {
    final client = http.Client();
    try {
      print('go.......');
      print('lat out.......${latitude}');
      print('long out.......${longitude}');
      final response = await client.post(
        Uri.parse(
          '${ApiEndPoint.baseUrl}${ApiEndPoint.addNewLocationEndPoint}',
        ),
        headers: {'Authorization': 'Bearer $token'},
        body: {'latitude': latitude, 'longitude': longitude},
      );

      log('send lat and long response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside send lat and long : ${message}');
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
