import 'package:json_annotation/json_annotation.dart';

part 'order_and_client_model.g.dart';

@JsonSerializable()
class OrderAndClientModel {
  bool? success;
  List<Clients>? data;

  OrderAndClientModel({this.success, this.data});

  factory OrderAndClientModel.fromJson(Map<String, dynamic> json) {
    return _$OrderAndClientModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$OrderAndClientModelToJson(this);
}

@JsonSerializable()
class Clients {
  int? id;

  @JsonKey(name: 'created_by')
  int? createdBy;

  @JsonKey(name: 'lead_id')
  int? leadId;

  @JsonKey(name: 'company_name')
  String? companyName;

  @JsonKey(name: 'client_name')
  String? clientName;

  @JsonKey(name: 'contact_number')
  String? contactNumber;

  String? email;
  String? address;

  @JsonKey(name: 'lead_source')
  String? leadSource;

  @JsonKey(name: 'customer_profile_id')
  int? customerProfileId;

  @JsonKey(name: 'customer_profile')
  String? customerProfile;

  String? note;

  @JsonKey(name: 'onboarding_date')
  DateTime? onboardingDate;

  String? status;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  @JsonKey(name: 'is_important')
  bool? isImportant;

  List<Meeting>? meetings;

  @JsonKey(name: 'call_logs')
  List<CallLogClientModel>? callLogs;

  Clients({
    this.id,
    this.createdBy,
    this.leadId,
    this.companyName,
    this.clientName,
    this.contactNumber,
    this.email,
    this.address,
    this.leadSource,
    this.customerProfileId,
    this.customerProfile,
    this.note,
    this.onboardingDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isImportant,
    this.meetings,
    this.callLogs,
  });

  factory Clients.fromJson(Map<String, dynamic> json) =>
      _$ClientsFromJson(json);

  Map<String, dynamic> toJson() => _$ClientsToJson(this);
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
class CallLogClientModel {
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

  CallLogClientModel({
    this.id,
    this.clientId,
    this.leadId,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CallLogClientModel.fromJson(Map<String, dynamic> json) =>
      _$CallLogClientModelFromJson(json);

  Map<String, dynamic> toJson() => _$CallLogClientModelToJson(this);
}
