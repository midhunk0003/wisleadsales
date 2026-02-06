import 'package:json_annotation/json_annotation.dart';

part 'expense_travel_type_model.g.dart';

@JsonSerializable()
class ExpenseTravelTypeModel {
  bool? success;
  List<ExpenseTravelData>? data;

  ExpenseTravelTypeModel({this.success, this.data});

  factory ExpenseTravelTypeModel.fromJson(Map<String, dynamic> json) {
    return _$ExpenseTravelTypeModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ExpenseTravelTypeModelToJson(this);
}

@JsonSerializable()
class ExpenseTravelData {
  int? id;
  String? name;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  ExpenseTravelData({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ExpenseTravelData.fromJson(Map<String, dynamic> json) =>
      _$ExpenseTravelDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseTravelDataToJson(this);
}
