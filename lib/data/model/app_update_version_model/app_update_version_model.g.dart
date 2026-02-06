// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUpdateVersionModel _$AppUpdateVersionModelFromJson(
  Map<String, dynamic> json,
) => AppUpdateVersionModel(
  success: json['success'] as bool?,
  data:
      json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppUpdateVersionModelToJson(
  AppUpdateVersionModel instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  androidVersion: json['android_version'] as String?,
  iosVersion: json['ios_version'] as String?,
  forceUpdate: json['force_update'] as bool?,
  message: json['message'] as String?,
  updateUrlAndroid: json['update_url_android'] as String?,
  updateUrlIos: json['update_url_ios'] as String?,
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'android_version': instance.androidVersion,
  'ios_version': instance.iosVersion,
  'force_update': instance.forceUpdate,
  'message': instance.message,
  'update_url_android': instance.updateUrlAndroid,
  'update_url_ios': instance.updateUrlIos,
};
