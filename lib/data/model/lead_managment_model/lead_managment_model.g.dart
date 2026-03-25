// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_managment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeadManagmentModel _$LeadManagmentModelFromJson(Map<String, dynamic> json) =>
    LeadManagmentModel(
      success: json['success'] as bool?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => LeadData.fromJson(e as Map<String, dynamic>))
              .toList(),
      lostLeads: (json['lost_leads'] as num?)?.toInt(),
      pendingFollowups: (json['pending_followups'] as num?)?.toInt(),
      convertedLeads: (json['converted_leads'] as num?)?.toInt(),
      totalLeads: (json['total_leads'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LeadManagmentModelToJson(LeadManagmentModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'total_leads': instance.totalLeads,
      'pending_followups': instance.pendingFollowups,
      'converted_leads': instance.convertedLeads,
      'lost_leads': instance.lostLeads,
    };

LeadData _$LeadDataFromJson(Map<String, dynamic> json) => LeadData(
  id: (json['id'] as num?)?.toInt(),
  clientName: json['client_name'] as String?,
  companyName: json['company_name'],
  contactNumber: json['contact_number'] as String?,
  email: json['email'] as String?,
  clientAddress: json['client_address'] as String?,
  leadStatusId: (json['lead_status_id'] as num?)?.toInt(),
  leadStatus: json['lead_status'] as String?,
  leadSource: json['lead_source'],
  customerProfileId: (json['customer_profile_id'] as num?)?.toInt(),
  customerProfile: json['customer_profile'] as String?,
  addNote: json['add_note'],
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'],
  meetings:
      (json['meetings'] as List<dynamic>?)
          ?.map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList(),
  callLogs:
      (json['call_logs'] as List<dynamic>?)
          ?.map((e) => CallLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
)..leadSourceId = json['lead_source_id'];

Map<String, dynamic> _$LeadDataToJson(LeadData instance) => <String, dynamic>{
  'id': instance.id,
  'client_name': instance.clientName,
  'company_name': instance.companyName,
  'contact_number': instance.contactNumber,
  'email': instance.email,
  'client_address': instance.clientAddress,
  'lead_status_id': instance.leadStatusId,
  'lead_status': instance.leadStatus,
  'customer_profile_id': instance.customerProfileId,
  'customer_profile': instance.customerProfile,
  'lead_source_id': instance.leadSourceId,
  'lead_source': instance.leadSource,
  'add_note': instance.addNote,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt,
  'meetings': instance.meetings,
  'call_logs': instance.callLogs,
};

Meeting _$MeetingFromJson(Map<String, dynamic> json) => Meeting(
  id: (json['id'] as num?)?.toInt(),
  clientId: (json['client_id'] as num?)?.toInt(),
  leadId: json['lead_id'],
  title: json['title'] as String?,
  date: json['date'],
  timeFrom: json['time_from'],
  timeTo: json['time_to'],
  meetingDatetime:
      json['meeting_datetime'] == null
          ? null
          : DateTime.parse(json['meeting_datetime'] as String),
  meetingType: json['meeting_type'],
  description: json['description'],
  status: json['status'] as String?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'],
);

Map<String, dynamic> _$MeetingToJson(Meeting instance) => <String, dynamic>{
  'id': instance.id,
  'client_id': instance.clientId,
  'lead_id': instance.leadId,
  'title': instance.title,
  'date': instance.date,
  'time_from': instance.timeFrom,
  'time_to': instance.timeTo,
  'meeting_datetime': instance.meetingDatetime?.toIso8601String(),
  'meeting_type': instance.meetingType,
  'description': instance.description,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt,
};

CallLogModel _$CallLogModelFromJson(Map<String, dynamic> json) => CallLogModel(
  id: (json['id'] as num?)?.toInt(),
  clientId: (json['client_id'] as num?)?.toInt(),
  leadId: (json['lead_id'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  language: json['language'] as String?,
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  updatedAt:
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'],
);

Map<String, dynamic> _$CallLogModelToJson(CallLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'lead_id': instance.leadId,
      'notes': instance.notes,
      'language': instance.language,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt,
    };
