import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/expanse_model/expanse_model.dart';
import 'package:wisdeals/data/model/expanse_model/expense_travel_type_model/expense_travel_type_model.dart';
import 'package:wisdeals/data/model/expanse_model/expenses_payment_mode_model/expenses_payment_mode_model.dart';
import 'package:wisdeals/domain/repository/expanse_repository.dart';

class ExpanseRepositoryImpli implements ExpanseRepository {
  @override
  Future<Either<Failure, Success>> addExpanse(
    String? token,
    String? clientName,
    String? companyName,
    String? expanseTypeId,
    String? amount,
    String? paymentModeId,
    String? file,
    String? note,
  ) async {
    final client = http.Client();

    try {
      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.addExpenseEndPoint}',
      );
      print('go add expanse  .......');
      print('FILE : ${file}.......');
      final request = http.MultipartRequest('POST', uri);
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      // Add form fields
      request.fields['client_name'] = clientName ?? '';
      request.fields['company_name'] = companyName ?? '';
      request.fields['expense_type_id'] = expanseTypeId ?? '';
      request.fields['amount'] = amount ?? '';
      request.fields['payment_mode_id'] = paymentModeId ?? '';
      request.fields['notes'] = note ?? '';

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
              'receipt',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('response add expanse: ${response.statusCode}');
      log('response body expanse add: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside expanse add  : ${message}');
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
  Future<Either<Failure, ExpanseModel>> getExpanse(
    String? token,
    String? status,
  ) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.expenseListEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
        body: {'status': status},
      );

      log("expanse list  : ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final expanseList = ExpanseModel.fromJson(data);
        print('expanse list inside : ${expanseList}');
        return Right(expanseList);
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
  Future<Either<Failure, Success>> updateExpanse(
    String? token,
    String? id,
    String? clientName,
    String? companyName,
    String? expanseTypeId,
    String? amount,
    String? paymentModeId,
    String? file,
    String? note,
  ) async {
    final client = http.Client();

    try {
      final uri = Uri.parse(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.updateExpenseEndPoint}',
      );
      print('go add expanse  .......');
      print('FILE : ${file}.......');
      final request = http.MultipartRequest('POST', uri);
      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      // Add form fields
      request.fields['id'] = id ?? '';
      request.fields['client_name'] = clientName ?? '';
      request.fields['company_name'] = companyName ?? '';
      request.fields['expense_type_id'] = expanseTypeId ?? '';
      request.fields['amount'] = amount ?? '';
      request.fields['payment_mode_id'] = paymentModeId ?? '';
      request.fields['notes'] = note ?? '';

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
              'receipt',
              imageBytes,
              filename: fileImage.path.split('/').last,
            ),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('response add expanse: ${response.statusCode}');
      log('response body expanse add: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside expanse add  : ${message}');
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
  Future<Either<Failure, List<ExpensesPaymentModeList>?>> getExpensePaymentMode(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.paymentModeEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get ExpensesPayment  list  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final ExpensesPayment =
            data.map((e) => ExpensesPaymentModeList.fromJson(e)).toList();
        print('ExpensesPayment    list inside : ${ExpensesPayment}');
        return Right(ExpensesPayment);
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
  Future<Either<Failure, List<ExpenseTravelData>>> getExpenseTravelType(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.expenseTypeEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get travel  list  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final ExpenseTravel =
            data.map((e) => ExpenseTravelData.fromJson(e)).toList();
        print('travel    list inside : ${ExpenseTravel}');
        return Right(ExpenseTravel);
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
