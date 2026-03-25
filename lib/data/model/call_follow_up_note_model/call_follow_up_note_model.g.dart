// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_follow_up_note_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallFollowUpNoteModel _$CallFollowUpNoteModelFromJson(
  Map<String, dynamic> json,
) => CallFollowUpNoteModel(
  success: json['success'] as bool?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => CallNote.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CallFollowUpNoteModelToJson(
  CallFollowUpNoteModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

CallNote _$CallNoteFromJson(Map<String, dynamic> json) => CallNote(
  id: _stringFromDynamic(json['id']),
  title: _stringFromDynamic(json['title']),
  status: _stringFromDynamic(json['status']),
  createdAt: _stringFromDynamic(json['created_at']),
  updatedAt: _stringFromDynamic(json['updated_at']),
);

Map<String, dynamic> _$CallNoteToJson(CallNote instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'status': instance.status,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
