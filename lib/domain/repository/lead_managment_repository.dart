import 'package:dartz/dartz.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_customer_profile_model/lead_customer_profile_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_status_model/lead_status_model.dart';
import 'package:wisdeals/data/model/lead_source_model/lead_source_model.dart';

abstract class LeadManagmentRepository {
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
  );

  Future<Either<Failure, LeadManagmentModel>> getLead(
    String? token,
    String? search,
    String? leadStatusId,
    String? currentPage,
  );
  Future<Either<Failure, Success>> deleteLead(String? token, String? id);
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
  );
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
  );

  Future<Either<Failure, Success>> addMeetingLead(
    String? token,
    String? leadid,
    String? date,
    String? timeFrom,
    String? timaTo,
    String? note,
  );

  Future<Either<Failure, Success>> addCallLogs(
    String? token,
    String? clientId,
    String? leadId,
    String? note,
  );

  Future<Either<Failure, List<LeadStatus>?>> getLeadStatus(String? token);

  Future<Either<Failure, List<CustomerProfileList>?>> getCustomerProfile(
    String? token,
  );

  Future<Either<Failure, List<LeadSourceList>?>> getLeadSource(String? token);
  Future<Either<Failure, Success>> deleteLeadMeeting(
    String? token,
    String? meetingId,
  );
}
