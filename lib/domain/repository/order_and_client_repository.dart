import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';

abstract class OrderAndClientRepository {
  Future<Either<Failure, List<Clients>>> getClients(
    String? token,
    String? page,
    String? status,
    String? customerProfileId,
  );
  Future<Either<Failure, Success>> deleteClients(String? token, String? id);
  Future<Either<Failure, Success>> addMeetingClient(
    String? token,
    String? leadid,
    String? date,
    String? timeFrom,
    String? timaTo,
    String? note,
  );
  Future<Either<Failure, Success>> addCallLogsClient(
    String? token,
    String? clientId,
    String? leadId,
    String? note,
  );

  Future<Either<Failure, Success>> updateClient(
    String? token,
    String? id,
    String? companyName,
    String? clientName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? status,
  );
  Future<Either<Failure, Success>> markAsImportant(
    String? token,
    String? id,
    String? isImportant,
  );

  Future<Either<Failure, Success>> deleteClientMeeting(
    String? token,
    String? clientMeetingId,
  );
}
