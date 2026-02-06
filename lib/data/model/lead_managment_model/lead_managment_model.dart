import 'package:json_annotation/json_annotation.dart';

part 'lead_managment_model.g.dart';

@JsonSerializable()
class LeadManagmentModel {
  bool? success;
  List<LeadData>? data;

  @JsonKey(name: 'total_leads')
  final int? totalLeads;

  @JsonKey(name: 'pending_followups')
  final int? pendingFollowups;

  @JsonKey(name: 'converted_leads')
  final int? convertedLeads;

  @JsonKey(name: 'lost_leads')
  final int? lostLeads;

  LeadManagmentModel({
    this.success,
    this.data,
    this.lostLeads,
    this.pendingFollowups,
    this.convertedLeads,
    this.totalLeads,
  });

  factory LeadManagmentModel.fromJson(Map<String, dynamic> json) {
    return _$LeadManagmentModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeadManagmentModelToJson(this);
}

@JsonSerializable()
class LeadData {
  int? id;
  @JsonKey(name: 'client_name')
  String? clientName;
  @JsonKey(name: 'company_name')
  dynamic companyName;
  @JsonKey(name: 'contact_number')
  String? contactNumber;
  String? email;
  @JsonKey(name: 'client_address')
  String? clientAddress;
  @JsonKey(name: 'lead_status_id')
  int? leadStatusId;
  @JsonKey(name: 'lead_status')
  String? leadStatus;
  @JsonKey(name: 'customer_profile_id')
  int? customerProfileId;
  @JsonKey(name: 'customer_profile')
  String? customerProfile;
  @JsonKey(name: 'lead_source_id')
  dynamic leadSourceId;
  @JsonKey(name: 'lead_source')
  dynamic leadSource;
  @JsonKey(name: 'add_note')
  dynamic addNote;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;
  List<Meeting>? meetings;
  @JsonKey(name: 'call_logs')
  List<CallLogModel>? callLogs;

  LeadData({
    this.id,
    this.clientName,
    this.companyName,
    this.contactNumber,
    this.email,
    this.clientAddress,
    this.leadStatusId,
    this.leadStatus,
    this.leadSource,
    this.customerProfileId,
    this.customerProfile,
    this.addNote,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.meetings,
    this.callLogs,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) =>
      _$LeadDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeadDataToJson(this);
}

@JsonSerializable()
class Meeting {
  int? id;
  @JsonKey(name: 'client_id')
  int? clientId;
  @JsonKey(name: 'lead_id')
  dynamic leadId;
  String? title;
  dynamic date;
  @JsonKey(name: 'time_from')
  dynamic timeFrom;
  @JsonKey(name: 'time_to')
  dynamic timeTo;
  @JsonKey(name: 'meeting_datetime')
  DateTime? meetingDatetime;
  @JsonKey(name: 'meeting_type')
  dynamic meetingType;
  dynamic description;
  String? status;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  Meeting({
    this.id,
    this.clientId,
    this.leadId,
    this.title,
    this.date,
    this.timeFrom,
    this.timeTo,
    this.meetingDatetime,
    this.meetingType,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return _$MeetingFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MeetingToJson(this);
}

@JsonSerializable()
class CallLogModel {
  int? id;
  @JsonKey(name: 'client_id')
  int? clientId;
  @JsonKey(name: 'lead_id')
  int? leadId;
  String? notes;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  CallLogModel({
    this.id,
    this.clientId,
    this.leadId,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CallLogModel.fromJson(Map<String, dynamic> json) =>
      _$CallLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$CallLogModelToJson(this);
}
