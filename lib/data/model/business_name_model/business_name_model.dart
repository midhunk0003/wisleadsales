import 'package:json_annotation/json_annotation.dart';

part 'business_name_model.g.dart';

@JsonSerializable()
class BusinessNameModel {
  bool? success;
  List<BusinessName>? data;

  BusinessNameModel({this.success, this.data});

  factory BusinessNameModel.fromJson(Map<String, dynamic> json) {
    return _$BusinessNameModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BusinessNameModelToJson(this);
}

@JsonSerializable()
class BusinessName {
  int? id;
  String? name;
  bool? status;
  @JsonKey(name: 'created_at')
  dynamic createdAt;
  @JsonKey(name: 'updated_at')
  dynamic updatedAt;

  BusinessName({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BusinessName.fromJson(Map<String, dynamic> json) =>
      _$BusinessNameFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessNameToJson(this);
}
