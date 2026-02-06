import 'package:json_annotation/json_annotation.dart';

part 'lead_customer_profile_model.g.dart';

@JsonSerializable()
class LeadCustomerProfileModel {
  bool? success;
  List<CustomerProfileList>? data;

  LeadCustomerProfileModel({this.success, this.data});

  factory LeadCustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return _$LeadCustomerProfileModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LeadCustomerProfileModelToJson(this);
}

@JsonSerializable()
class CustomerProfileList {
  int? id;
  String? name;
  @JsonKey(name: 'created_at')
  dynamic createdAt;
  @JsonKey(name: 'updated_at')
  dynamic updatedAt;

  CustomerProfileList({this.id, this.name, this.createdAt, this.updatedAt});

  factory CustomerProfileList.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileListFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerProfileListToJson(this);
}
