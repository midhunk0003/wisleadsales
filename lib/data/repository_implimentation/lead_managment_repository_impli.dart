import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_customer_profile_model/lead_customer_profile_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_status_model/lead_status_model.dart';
import 'package:wisdeals/data/model/lead_source_model/lead_source_model.dart';
import 'package:wisdeals/domain/repository/lead_managment_repository.dart';

class LeadManagmentRepositoryImpli extends LeadManagmentRepository {
  @override
  Future<Either<Failure, Success>> addLead(
    String? token,
    String? clientName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? leadSource,
    String? addNote,
    String? leadStatusId,
    String? leadStatus,
    String? customerProfileId,
    String? customerProfile,
  ) async {
    final client = http.Client();
    try {
      print('go.......');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.addLeadsEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "client_name": clientName ?? '',
          "company_name": companyName ?? '',
          "contact_number": contactNumber ?? '',
          "email": email ?? '',
          "client_address": clientAddress ?? '',
          'lead_status_id': leadStatusId ?? '',
          "lead_status": leadStatus ?? '',
          "lead_source_id": leadSource ?? '',
          "add_note": addNote ?? '',
          "customer_profile_id": customerProfileId ?? '',
          "customer_profile": customerProfile ?? '',
        },
      );

      log('lead response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside lead response : ${message}');
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
  Future<Either<Failure, LeadManagmentModel>> getLead(
    String? token,
    String? search,
    String? leadStatusId,
    String? currentPage,
  ) async {
    final client = http.Client();

    try {
      final response = await client.post(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.leadsEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "search": search ?? '',
          "lead_status_id": leadStatusId ?? '',
          'page': currentPage ?? '',
        },
      );

      log("lead list  : ${response.body}");

      if (response.statusCode == 200) {
        // final List<dynamic> data = json.decode(response.body)['data'];
        // final listOfLead = data.map((e) => LeadData.fromJson(e)).toList();
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        // Convert JSON into LeadManagementModel
        final leadModel = LeadManagmentModel.fromJson(jsonMap);

        print('lead list inside : ${leadModel}');
        return Right(leadModel);
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
      log('Unable to process your request right now.: $e');
      return Left(
        OtherFailureNon200('Unable to process your request right now.'),
      );
    } finally {
      // Optional cleanup logic
      log('API call completed'); // for debugging
      client.close(); //if you created an HttpClient manually
    }
  }

  @override
  Future<Either<Failure, Success>> deleteLead(String? token, String? id) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.deleteLeadsEndPoint}/$id",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("lead delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('lead delete inside : ${data['message']}');
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
  Future<Either<Failure, Success>> updateLead(
    String? token,
    String? id,
    String? clientName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? leadSource,
    String? addNote,
    String? leadStatusId,
    String? leadStatus,
    String? customerProfileId,
    String? customerProfile,
  ) async {
    final client = http.Client();
    try {
      print('go edit.......');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.updateLeadsEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "id": id,
          "client_name": clientName ?? '',
          "company_name": companyName ?? '',
          "contact_number": contactNumber ?? '',
          "email": email ?? '',
          "client_address": clientAddress ?? '',
          'lead_status_id': leadStatusId ?? '',
          "lead_status": leadStatus ?? '',
          "lead_source_id": leadSource ?? '',
          "add_note": addNote ?? '',
          "customer_profile_id": customerProfileId ?? '',
          "customer_profile": customerProfile ?? '',
        },
      );

      log('lead update response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside lead update response : ${message}');
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
  Future<Either<Failure, Success>> leadConvertToclient(
    String? token,
    String? id,
    String? clientName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? leadSource,
    String? addNote,
    String? leadStatus,
    String? customerProfile,
  ) async {
    final client = http.Client();
    try {
      print('go lead convert to client .......');
      final response = await client.post(
        Uri.parse(
          '${ApiEndPoint.baseUrl}${ApiEndPoint.leadsConvertToClientEndPoint}',
        ),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "id": id,
          "client_name": clientName ?? '',
          "company_name": companyName ?? '',
          "contact_number": contactNumber ?? '',
          "email": email ?? '',
          "client_address": clientAddress ?? '',
          "lead_status": leadStatus ?? '',
          "lead_source": leadSource ?? '',
          "add_note": addNote ?? '',
          "customer_profile": customerProfile ?? '',
        },
      );

      log('lead convert to client  response : ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final message = data['message'];
        print('inside lead convert to client response : ${message}');
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
  Future<Either<Failure, Success>> addMeetingLead(
    String? token,
    String? leadid,
    String? date,
    String? timeFrom,
    String? timaTo,
    String? note,
  ) async {
    final client = http.Client();
    try {
      print('go lead add meating .......');
      print('go lead add meating .......${leadid}');
      print('go lead add meating .......${date}');
      print('go lead add meating .......${timeFrom}');
      print('go lead add meating .......${timaTo}');
      print('go lead add meating .......${note}');
      final response = await client.post(
        Uri.parse('${ApiEndPoint.baseUrl}${ApiEndPoint.addMeetingEndPoint}'),
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "lead_id": leadid,
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
  Future<Either<Failure, Success>> addCallLogs(
    String? token,
    String? clientId,
    String? leadId,
    String? note,
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
          "notes": note ?? '',
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
  Future<Either<Failure, List<LeadStatus>?>> getLeadStatus(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.leadStatusSummaryEndPoint}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get lead status filter listxxxxxxxxxxxxxxx  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final leadStatusList = data.map((e) => LeadStatus.fromJson(e)).toList();
        // final Map<String, dynamic> jsonMap = json.decode(response.body);
        // Convert JSON into LeadManagementModel
        // final leadModel = LeadManagmentModel.fromJson(leadStatusList);
        print('lead status list inside : ${leadStatusList}');
        return Right(leadStatusList);
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
          print("XXXXXXXXXXXXX LEAD status summery${e}");
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
  Future<Either<Failure, List<CustomerProfileList>?>> getCustomerProfile(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.customerProfileEndPoint}",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get Customer profile  list  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final CustomerProfile =
            data.map((e) => CustomerProfileList.fromJson(e)).toList();
        // final Map<String, dynamic> jsonMap = json.decode(response.body);
        // Convert JSON into LeadManagementModel
        // final leadModel = LeadManagmentModel.fromJson(leadStatusList);
        print('Customer profile   list inside : ${CustomerProfile}');
        return Right(CustomerProfile);
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
  Future<Either<Failure, List<LeadSourceList>?>> getLeadSource(
    String? token,
  ) async {
    final client = http.Client();

    try {
      final response = await client.get(
        Uri.parse("${ApiEndPoint.baseUrl}${ApiEndPoint.leadSourceEndPoint}"),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("get leadSource listxxxxxxxxxxxxxxx  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        final leadSourceList =
            data.map((e) => LeadSourceList.fromJson(e)).toList();
        // final Map<String, dynamic> jsonMap = json.decode(response.body);
        // Convert JSON into LeadManagementModel
        // final leadModel = LeadManagmentModel.fromJson(leadStatusList);
        print('lead Source  list inside : ${leadSourceList}');
        return Right(leadSourceList);
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
  Future<Either<Failure, Success>> deleteLeadMeeting(
    String? token,
    String? meetingId,
  ) async {
    final client = http.Client();

    try {
      final response = await client.delete(
        Uri.parse(
          "${ApiEndPoint.baseUrl}${ApiEndPoint.deleteMeetingEndPoint}/$meetingId",
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      log("lead meeting delete  : ${response.body}");

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('lead meeting  delete inside : ${data['message']}');
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
