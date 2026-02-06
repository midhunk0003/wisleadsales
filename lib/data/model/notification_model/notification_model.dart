import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  bool? success;
  int? count;
  List<NotificationList>? data;

  NotificationModel({this.success, this.count, this.data});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return _$NotificationModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class NotificationList {
  int? id;
  String? title;
  String? message;
  String? audience;
  @JsonKey(name: 'user_id')
  int? userId;
  String? type;
  @JsonKey(name: 'posted_by')
  dynamic postedBy;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;
  @JsonKey(name: 'is_read')
  bool? isRead;

  NotificationList({
    this.id,
    this.title,
    this.message,
    this.audience,
    this.userId,
    this.type,
    this.postedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isRead,
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      _$NotificationListFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationListToJson(this);
}
