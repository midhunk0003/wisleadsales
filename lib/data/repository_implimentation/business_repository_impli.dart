import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/business_client_name_model/business_client_name_model.dart';
import 'package:wisdeals/data/model/business_list_model/business_list_model.dart';
import 'package:wisdeals/data/model/business_name_model/business_name_model.dart';
import 'package:wisdeals/domain/repository/business_repository.dart';

class BusinessRepositoryImpli implements BusinessRepository {
  @override
  Future<Either<Failure, BusinessClientNameModel>> getBusinessClientName(
    String? token,
    String? search,
    String? currentPage,
  ) async {
    print('current page ${currentPage}');
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.clientNameEndPoint}?per_page=${currentPage}&search=${search}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("business client name : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final clientsList = BusinessClientNameModel.fromJson(data);
        print('business clients name  inside : ${clientsList}');
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

  @override
  Future<Either<Failure, List<BusinessName>>> getBusinessName(
    String? token,
    String? search,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.businessNameEndPoint}?search=${search}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("business  name : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final clientsList = data.map((e) => BusinessName.fromJson(e)).toList();
        print('Business name inside : $clientsList');
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

  @override
  Future<Either<Failure, Success>> addBusiness(
    String? token,
    String? clientId,
    String? businessId,
    String? businessCost,
    String? businessType,
  ) async {
    final client = http.Client();
    try {
      print('go.......');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.businessAddEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "client_id": clientId,
          "business_name_id": businessId,
          "total_business_cost": businessCost,
          "business_title": businessType,
        },
      );

      log('add business : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside add business : ${message}');
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
  Future<Either<Failure, BusinessData>> getAllBusinessData(
    String? token,
    String? month,
    String? year,
    String? status,
    String? search,
    String? perpage,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.businessListEndPoint}?month=${month}&year=${year}&status=${status}&search=${search}&perpage=${perpage}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("business  All list : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body)['data'];
        final businessData = BusinessData.fromJson(data);
        print('Business All List inside : $businessData');
        return Right(businessData);
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
  Future<Either<Failure, Success>> addAmount(
    String? token,
    String? businessId,
    String? amount,
  ) async {
    final client = http.Client();
    try {
      print('go.......');
      final response = await client.post(
        Uri.parse(
          '${ApiEndPoint.baseUrl}${ApiEndPoint.businessAddCollectionsEndPoint}',
        ),
        headers: {'Authorization': 'Bearer $token'},
        body: {"business_id": businessId, "amount": amount},
      );

      log('add collected amount  : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print(' add collected amount inside: ${message}');
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
  Future<Either<Failure, Success>> deleteBusiness(
    String? token,
    String? businessId,
  ) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.businessDeleteEndPoint}/$businessId",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("business delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('business delete inside : ${data['message']}');
        return Right(Success(message: data['message']));
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
  Future<Either<Failure, Success>> deletePayment(
    String? token,
    String? paymentId,
  ) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.businessDeletecollectionsEndPoint}/$paymentId",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("payment delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('paymet delete inside : ${data['message']}');
        return Right(Success(message: data['message']));
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
