import 'package:json_annotation/json_annotation.dart';

part 'business_list_model.g.dart';

String? _stringFromDynamic(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class BusinessListModel {
  bool? success;
  BusinessData? data;

  BusinessListModel({this.success, this.data});

  factory BusinessListModel.fromJson(Map<String, dynamic> json) {
    return _$BusinessListModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BusinessListModelToJson(this);
}

@JsonSerializable()
class BusinessData {
  BusinessSummary? summary;
  List<BusinessListData>? businesses;

  BusinessData({this.summary, this.businesses});

  factory BusinessData.fromJson(Map<String, dynamic> json) =>
      _$BusinessDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessDataToJson(this);
}

@JsonSerializable()
class BusinessSummary {
  @JsonKey(name: 'target_amount', fromJson: _stringFromDynamic)
  String? targetAmount;

  @JsonKey(name: 'total_business', fromJson: _stringFromDynamic)
  String? totalBusiness;

  @JsonKey(name: 'total_collected', fromJson: _stringFromDynamic)
  String? totalCollected;

  @JsonKey(fromJson: _stringFromDynamic)
  String? percentage;

  @JsonKey(name: 'pending_count', fromJson: _stringFromDynamic)
  String? pendingCount;

  @JsonKey(name: 'completed_count', fromJson: _stringFromDynamic)
  String? completedCount;
  @JsonKey(name: 'total_count', fromJson: _stringFromDynamic)
  String? totalCount;

  @JsonKey(name: 'achieved_status', fromJson: _stringFromDynamic)
  String? achievedStatus;

  BusinessSummary({
    this.targetAmount,
    this.totalBusiness,
    this.totalCollected,
    this.percentage,
    this.pendingCount,
    this.completedCount,
    this.totalCount,
    this.achievedStatus,
  });

  factory BusinessSummary.fromJson(Map<String, dynamic> json) {
    return _$BusinessSummaryFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BusinessSummaryToJson(this);
}

@JsonSerializable()
class BusinessListData {
  @JsonKey(name: 'business_id', fromJson: _stringFromDynamic)
  String? businessId;

  @JsonKey(name: 'business_name', fromJson: _stringFromDynamic)
  String? businessName;

  @JsonKey(name: 'client_name', fromJson: _stringFromDynamic)
  String? clientName;

  @JsonKey(name: 'collection_pending_status', fromJson: _stringFromDynamic)
  String? collectionPendingStatus;

  @JsonKey(name: 'total_business_cost', fromJson: _stringFromDynamic)
  String? totalBusinessCost;

  @JsonKey(name: 'collected_business_cost', fromJson: _stringFromDynamic)
  String? collectedBusinessCost;

  @JsonKey(name: 'pending_collection', fromJson: _stringFromDynamic)
  String? pendingCollection;
  @JsonKey(name: 'created_at', fromJson: _stringFromDynamic)
  String? createdAt;
  @JsonKey(name: 'collected_payments')
  List<CollectedPaymentsList>? collectedPayments;

  BusinessListData({
    this.businessId,
    this.businessName,
    this.clientName,
    this.collectionPendingStatus,
    this.totalBusinessCost,
    this.collectedBusinessCost,
    this.pendingCollection,
    this.createdAt,
    this.collectedPayments,
  });

  factory BusinessListData.fromJson(Map<String, dynamic> json) {
    return _$BusinessListDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BusinessListDataToJson(this);
}

@JsonSerializable()
class CollectedPaymentsList {
  @JsonKey(name: 'id', fromJson: _stringFromDynamic)
  String? id;

  @JsonKey(name: 'amount', fromJson: _stringFromDynamic)
  String? amount;

  @JsonKey(name: 'collected_date', fromJson: _stringFromDynamic)
  String? collecteDate;

  CollectedPaymentsList({this.id, this.amount});

  factory CollectedPaymentsList.fromJson(Map<String, dynamic> json) {
    return _$CollectedPaymentsListFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CollectedPaymentsListToJson(this);
}
