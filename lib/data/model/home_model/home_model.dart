import 'package:json_annotation/json_annotation.dart';

part 'home_model.g.dart';

@JsonSerializable()
class HomeModel {
  bool? success;
  String? message;
  HomeDataModel? data;

  HomeModel({this.success, this.message, this.data});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return _$HomeModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$HomeModelToJson(this);
}

@JsonSerializable()
class HomeDataModel {
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'attendance_date')
  dynamic attendanceDate;
  @JsonKey(name: 'clock_in')
  dynamic clockIn;
  @JsonKey(name: 'clock_out')
  dynamic clockOut;
  dynamic latitude;
  dynamic longitude;
  dynamic km;
  bool? status;
  @JsonKey(name: 'updated_at')
  dynamic updatedAt;
  @JsonKey(name: 'created_at')
  dynamic createdAt;
  dynamic id;

  HomeDataModel({
    this.userId,
    this.attendanceDate,
    this.clockIn,
    this.clockOut,
    this.latitude,
    this.longitude,
    this.km,
    this.status,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) =>
      _$HomeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeDataModelToJson(this);
}
