import 'package:json_annotation/json_annotation.dart';

part 'expenses_payment_mode_model.g.dart';

@JsonSerializable()
class ExpensesPaymentModeModel {
  bool? success;
  List<ExpensesPaymentModeList>? data;

  ExpensesPaymentModeModel({this.success, this.data});

  factory ExpensesPaymentModeModel.fromJson(Map<String, dynamic> json) {
    return _$ExpensesPaymentModeModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ExpensesPaymentModeModelToJson(this);
}

@JsonSerializable()
class ExpensesPaymentModeList {
  int? id;
  String? name;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  ExpensesPaymentModeList({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ExpensesPaymentModeList.fromJson(Map<String, dynamic> json) =>
      _$ExpensesPaymentModeListFromJson(json);

  Map<String, dynamic> toJson() => _$ExpensesPaymentModeListToJson(this);
}
