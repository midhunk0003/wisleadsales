import 'package:json_annotation/json_annotation.dart';

part 'business_client_name_model.g.dart';

@JsonSerializable()
class BusinessClientNameModel {
  bool? success;
  @JsonKey(name: 'current_page')
  int? currentPage;
  List<BusinessClientName>? data;
  int? total;
  @JsonKey(name: 'last_page')
  int? lastPage;
  @JsonKey(name: 'per_page')
  int? perPage;
  String? message;

  BusinessClientNameModel({
    this.success,
    this.currentPage,
    this.data,
    this.total,
    this.lastPage,
    this.perPage,
    this.message,
  });

  factory BusinessClientNameModel.fromJson(Map<String, dynamic> json) {
    return _$BusinessClientNameModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BusinessClientNameModelToJson(this);
}

@JsonSerializable()
class BusinessClientName {
  int? id;
  @JsonKey(name: 'client_name')
  String? clientName;

  BusinessClientName({this.id, this.clientName});

  factory BusinessClientName.fromJson(Map<String, dynamic> json) =>
      _$BusinessClientNameFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessClientNameToJson(this);
}
