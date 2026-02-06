import 'package:json_annotation/json_annotation.dart';

part 'app_update_version_model.g.dart';

@JsonSerializable()
class AppUpdateVersionModel {
  bool? success;
  Data? data;

  AppUpdateVersionModel({this.success, this.data});

  factory AppUpdateVersionModel.fromJson(Map<String, dynamic> json) {
    return _$AppUpdateVersionModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AppUpdateVersionModelToJson(this);
}

@JsonSerializable()
class Data {
  @JsonKey(name: 'android_version')
  String? androidVersion;
  @JsonKey(name: 'ios_version')
  String? iosVersion;
  @JsonKey(name: 'force_update')
  bool? forceUpdate;
  String? message;
  @JsonKey(name: 'update_url_android')
  String? updateUrlAndroid;
  @JsonKey(name: 'update_url_ios')
  String? updateUrlIos;

  Data({
    this.androidVersion,
    this.iosVersion,
    this.forceUpdate,
    this.message,
    this.updateUrlAndroid,
    this.updateUrlIos,
  });

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
