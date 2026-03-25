import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/call_follow_up_languages/call_follow_up_languages.dart';
import 'package:wisdeals/data/model/call_follow_up_note_model/call_follow_up_note_model.dart';
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';
import 'package:wisdeals/domain/repository/order_and_client_repository.dart';

class OrderAndClientRepositoryImpli implements OrderAndClientRepository {
  @override
  Future<Either<Failure, OrderAndClientModel>> getClients(
    String? token,
    String? search,
    String? page,
    String? status,
    String? customerPriorityId,
  ) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.clientsEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'page': page ?? '',
          'search': search ?? '',
          'status': status ?? '',
          'customer_profile_id': customerPriorityId,
        },
      );

      log("clients list  : ${response.body}");

      if (response.statusCode == 200) {
        // final List<dynamic> data = json.decode(response.body)['data'];
        // final clientsList = data.map((e) => Clients.fromJson(e)).toList();
        // print('clients list inside : ${clientsList}');
        // return Right(clientsList);
        final dynamic data = json.decode(response.body);
        final clientsList = OrderAndClientModel.fromJson(data);
        print('clients list inside : ${clientsList}');
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
  Future<Either<Failure, Success>> deleteClients(
    String? token,
    String? id,
  ) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.deleteClientsEndPoint}/$id",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("client delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('client delete inside : ${data['message']}');
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
  Future<Either<Failure, Success>> addMeetingClient(
    String? token,
    String? clientId,
    String? date,
    String? timeFrom,
    String? timaTo,
    String? note,
  ) async {
    final client = http.Client();
    try {
      print('go client add meating .......');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.addMeetingEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "client_id": clientId,
          "date": date ?? '',
          "time_from": timeFrom ?? '',
          "time_to": timaTo ?? '',
          "note": note ?? '',
        },
      );

      log('lead add meeting : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside lead add meeting : ${message}');
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
  Future<Either<Failure, Success>> addCallLogsClient(
    String? token,
    String? clientId,
    String? leadId,
    String? noteId,
    String? languageId,
  ) async {
    final client = http.Client();
    try {
      print('go call logs add .......');
      final response = await client.post(
        Uri.parse(
          '${ApiEndPoint.baseUrl}${ApiEndPoint.addcallLogNotesEndPoint}',
        ),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "client_id": clientId ?? '',
          "lead_id": leadId ?? '',
          "note_id": noteId ?? '',
          "language_id": languageId ?? '',
        },
      );

      log('call loga add: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside add call log: ${message}');
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
  Future<Either<Failure, Success>> updateClient(
    String? token,
    String? id,
    String? companyName,
    String? clientName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? status,
  ) async {
    final client = http.Client();
    try {
      print('go edit client .......');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.updateClientsEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "id": id,
          "company_name": companyName ?? '',
          "client_name": clientName ?? '',
          "contact_number": contactNumber ?? '',
          "email": email ?? '',
          "client_address": clientAddress ?? '',
          "status": status ?? '',
        },
      );

      log('client  update response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside client  update response : ${message}');
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
  Future<Either<Failure, Success>> markAsImportant(
    String? token,
    String? id,
    String? isImportant,
  ) async {
    final client = http.Client();
    try {
      print('go mark as important  .......');
      final response = await client.post(
        Uri.parse(
          '${ApiEndPoint.baseUrl}${ApiEndPoint.clientsUpdateImportantEndPoint}',
        ),
        headers: {'Authorization': 'Bearer $token'},
        body: {"id": id, "is_important": isImportant ?? ''},
      );

      log('mark   important response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside client  mark important response : ${message}');
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
  Future<Either<Failure, Success>> deleteClientMeeting(
    String? token,
    String? clientMeetingId,
  ) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.deleteMeetingEndPoint}/$clientMeetingId",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("client meeting delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('client meeting  delete inside : ${data['message']}');
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
  Future<Either<Failure, List<CallLanguage>?>> getOrderCallLAnguage(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.leadCallLanguageEndPoint}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get client call language listxxxxxxxxxxxxxxx  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final leadLanguage = data.map((e) => CallLanguage.fromJson(e)).toList();
        // final Map<String, dynamic> jsonMap = json.decode(response.body);
        // Convert JSON into LeadManagementModel
        // final leadModel = LeadManagmentModel.fromJson(leadStatusList);
        print('get client call language  list inside : ${leadLanguage}');
        return Right(leadLanguage);
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
  Future<Either<Failure, List<CallNote>?>> getOrderCallNote(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.leadCallNotesEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get client call note listxxxxxxxxxxxxxxx  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final leadCallNote = data.map((e) => CallNote.fromJson(e)).toList();
        // final Map<String, dynamic> jsonMap = json.decode(response.body);
        // Convert JSON into LeadManagementModel
        // final leadModel = LeadManagmentModel.fromJson(leadStatusList);
        print('get client call note  list inside : ${leadCallNote}');
        return Right(leadCallNote);
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
