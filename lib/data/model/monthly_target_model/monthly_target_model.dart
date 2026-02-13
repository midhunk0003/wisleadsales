import 'package:json_annotation/json_annotation.dart';

part 'monthly_target_model.g.dart';

@JsonSerializable()
class MonthlyTargetModel {
  bool? success;
  String? message;
  ProjectMonthData? data;

  MonthlyTargetModel({this.success, this.message, this.data});

  factory MonthlyTargetModel.fromJson(Map<String, dynamic> json) {
    return _$MonthlyTargetModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$MonthlyTargetModelToJson(this);
}

@JsonSerializable()
class ProjectMonthData {
  @JsonKey(name: 'user_id')
  int? userId;
  String? name;
  int? year;
  List<Target>? targets;

  ProjectMonthData({this.userId, this.name, this.year, this.targets});

  factory ProjectMonthData.fromJson(Map<String, dynamic> json) =>
      _$ProjectMonthDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMonthDataToJson(this);
}

@JsonSerializable()
class Target {
  String? month;
  @JsonKey(name: 'month_number')
  int? monthNumber;
  @JsonKey(name: 'target_amount')
  int? targetAmount;
  @JsonKey(name: 'achieved_amount')
  int? achievedAmount;
  @JsonKey(name: 'pending_amount')
  int? pendingAmount;
  int? percentage;
  String? status;

  Target({
    this.month,
    this.monthNumber,
    this.targetAmount,
    this.achievedAmount,
    this.pendingAmount,
    this.percentage,
    this.status,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return _$TargetFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TargetToJson(this);
}
