// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      success: json['success'] as bool?,
      count: (json['count'] as num?)?.toInt(),
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => NotificationList.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'count': instance.count,
      'data': instance.data,
    };

NotificationList _$NotificationListFromJson(Map<String, dynamic> json) =>
    NotificationList(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      message: json['message'] as String?,
      audience: json['audience'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      type: json['type'] as String?,
      postedBy: json['posted_by'],
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'],
      isRead: json['is_read'] as bool?,
    );

Map<String, dynamic> _$NotificationListToJson(NotificationList instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'audience': instance.audience,
      'user_id': instance.userId,
      'type': instance.type,
      'posted_by': instance.postedBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'deleted_at': instance.deletedAt,
      'is_read': instance.isRead,
    };
