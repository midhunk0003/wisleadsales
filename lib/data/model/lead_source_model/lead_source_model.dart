import 'package:json_annotation/json_annotation.dart';

part 'lead_source_model.g.dart';

@JsonSerializable()
class LeadSourceModel {
  bool? success;
  List<LeadSourceList>? data;

  LeadSourceModel({this.success, this.data});

  factory LeadSourceModel.fromJson(Map<String, dynamic> json) {
    return _$LeadSourceModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeadSourceModelToJson(this);
}

@JsonSerializable()
class LeadSourceList {
  int? id;
  String? source;
  @JsonKey(name: 'created_at')
  dynamic createdAt;
  @JsonKey(name: 'updated_at')
  dynamic updatedAt;

  LeadSourceList({this.id, this.source, this.createdAt, this.updatedAt});

  factory LeadSourceList.fromJson(Map<String, dynamic> json) =>
      _$LeadSourceListFromJson(json);

  Map<String, dynamic> toJson() => _$LeadSourceListToJson(this);
}
