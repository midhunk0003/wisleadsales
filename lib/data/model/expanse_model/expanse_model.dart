import 'package:json_annotation/json_annotation.dart';

part 'expanse_model.g.dart';

@JsonSerializable()
class ExpanseModel {
  bool? success;
  String? message;
  List<ExpanseData>? data;
  @JsonKey(name: 'Pending')
  String? pending;
  @JsonKey(name: 'Approved')
  String? approved;
  @JsonKey(name: 'Rejected')
  String? rejected;
  String? total;

  ExpanseModel({
    this.success,
    this.message,
    this.data,
    this.pending,
    this.approved,
    this.rejected,
    this.total,
  });

  factory ExpanseModel.fromJson(Map<String, dynamic> json) {
    return _$ExpanseModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ExpanseModelToJson(this);
}

@JsonSerializable()
class ExpanseData {
  int? id;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'client_name')
  String? clientName;
  @JsonKey(name: 'company_name')
  String? companyName;
  @JsonKey(name: 'expense_type_id')
  int? expenseTypeId;
  @JsonKey(name: 'expense_type')
  String? expenseType;
  String? amount;
  @JsonKey(name: 'payment_mode_id')
  int? paymentModeId;
  @JsonKey(name: 'payment_mode')
  String? paymentMode;
  dynamic receipt;
  String? notes;
  String? status;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;
  @JsonKey(name: 'deleted_at')
  dynamic deletedAt;

  ExpanseData({
    this.id,
    this.userId,
    this.clientName,
    this.companyName,
    this.expenseTypeId,
    this.expenseType,
    this.amount,
    this.paymentModeId,
    this.paymentMode,
    this.receipt,
    this.notes,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory ExpanseData.fromJson(Map<String, dynamic> json) =>
      _$ExpanseDataFromJson(json);

  Map<String, dynamic> toJson() => _$ExpanseDataToJson(this);
}
