import 'package:json_annotation/json_annotation.dart';

part 'lead_status_model.g.dart';

@JsonSerializable()
class LeadStatusModel {
  bool? success;
  List<LeadStatus>? data;

  LeadStatusModel({this.success, this.data});

  factory LeadStatusModel.fromJson(Map<String, dynamic> json) {
    return _$LeadStatusModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeadStatusModelToJson(this);
}

@JsonSerializable()
class LeadStatus {
  int? id;
  String? status;
  @JsonKey(name: 'lead_count')
  dynamic leadCount;

  LeadStatus({this.id, this.status, this.leadCount});

  factory LeadStatus.fromJson(Map<String, dynamic> json) =>
      _$LeadStatusFromJson(json);

  Map<String, dynamic> toJson() => _$LeadStatusToJson(this);
}
