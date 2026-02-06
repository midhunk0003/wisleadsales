import 'package:json_annotation/json_annotation.dart';

part 'leave_type_model.g.dart';

@JsonSerializable()
class LeaveTypeModel {
  bool? success;
  List<LeaveTypeData>? data;

  LeaveTypeModel({this.success, this.data});

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return _$LeaveTypeModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeaveTypeModelToJson(this);
}

@JsonSerializable()
class LeaveTypeData {
  int? id;
  String? name;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  LeaveTypeData({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory LeaveTypeData.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeDataFromJson(json);

  Map<String, dynamic> toJson() => _$LeaveTypeDataToJson(this);
}
