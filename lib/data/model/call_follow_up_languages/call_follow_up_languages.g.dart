// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_follow_up_languages.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallFollowUpLanguages _$CallFollowUpLanguagesFromJson(
  Map<String, dynamic> json,
) => CallFollowUpLanguages(
  success: json['success'] as bool?,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => CallLanguage.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CallFollowUpLanguagesToJson(
  CallFollowUpLanguages instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

CallLanguage _$CallLanguageFromJson(Map<String, dynamic> json) => CallLanguage(
  id: _stringFromDynamic(json['id']),
  name: _stringFromDynamic(json['name']),
  status: _stringFromDynamic(json['status']),
  createdAt: _stringFromDynamic(json['created_at']),
  updatedAt: _stringFromDynamic(json['updated_at']),
);

Map<String, dynamic> _$CallLanguageToJson(CallLanguage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
