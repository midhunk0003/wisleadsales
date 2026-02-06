// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeModel _$HomeModelFromJson(Map<String, dynamic> json) => HomeModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data:
      json['data'] == null
          ? null
          : HomeDataModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$HomeModelToJson(HomeModel instance) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
};

HomeDataModel _$HomeDataModelFromJson(Map<String, dynamic> json) =>
    HomeDataModel(
      userId: (json['user_id'] as num?)?.toInt(),
      attendanceDate: json['attendance_date'],
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      km: json['km'],
      status: json['status'] as bool?,
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
    );

Map<String, dynamic> _$HomeDataModelToJson(HomeDataModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'attendance_date': instance.attendanceDate,
      'clock_in': instance.clockIn,
      'clock_out': instance.clockOut,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'km': instance.km,
      'status': instance.status,
      'updated_at': instance.updatedAt,
      'created_at': instance.createdAt,
      'id': instance.id,
    };
