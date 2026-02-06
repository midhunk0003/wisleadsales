// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_and_client_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderAndClientModel _$OrderAndClientModelFromJson(Map<String, dynamic> json) =>
    OrderAndClientModel(
      success: json['success'] as bool?,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Clients.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$OrderAndClientModelToJson(
  OrderAndClientModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

Clients _$ClientsFromJson(Map<String, dynamic> json) => Clients(
  id: (json['id'] as num?)?.toInt(),
  createdBy: (json['created_by'] as num?)?.toInt(),
  leadId: (json['lead_id'] as num?)?.toInt(),
  companyName: json['company_name'] as String?,
  clientName: json['client_name'] as String?,
  contactNumber: json['contact_number'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  leadSource: json['lead_source'] as String?,
  customerProfileId: (json['customer_profile_id'] as num?)?.toInt(),
  customerProfile: json['customer_profile'] as String?,
  note: json['note'] as String?,
  onboardingDate:
      json['onboarding_date'] == null
          ? null
          : DateTime.parse(json['onboarding_date'] as String),
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
  isImportant: json['is_important'] as bool?,
  meetings:
      (json['meetings'] as List<dynamic>?)
          ?.map((e) => Meeting.fromJson(e as Map<String, dynamic>))
          .toList(),
  callLogs:
      (json['call_logs'] as List<dynamic>?)
          ?.map((e) => CallLogClientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ClientsToJson(Clients instance) => <String, dynamic>{
  'id': instance.id,
  'created_by': instance.createdBy,
  'lead_id': instance.leadId,
  'company_name': instance.companyName,
  'client_name': instance.clientName,
  'contact_number': instance.contactNumber,
  'email': instance.email,
  'address': instance.address,
  'lead_source': instance.leadSource,
  'customer_profile_id': instance.customerProfileId,
  'customer_profile': instance.customerProfile,
  'note': instance.note,
  'onboarding_date': instance.onboardingDate?.toIso8601String(),
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt,
  'is_important': instance.isImportant,
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

CallLogClientModel _$CallLogClientModelFromJson(Map<String, dynamic> json) =>
    CallLogClientModel(
      id: (json['id'] as num?)?.toInt(),
      clientId: (json['client_id'] as num?)?.toInt(),
      leadId: (json['lead_id'] as num?)?.toInt(),
      notes: json['notes'] as String?,
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

Map<String, dynamic> _$CallLogClientModelToJson(CallLogClientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'lead_id': instance.leadId,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt,
    };
