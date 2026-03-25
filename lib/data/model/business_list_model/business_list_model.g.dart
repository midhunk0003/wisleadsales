// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessListModel _$BusinessListModelFromJson(Map<String, dynamic> json) =>
    BusinessListModel(
      success: json['success'] as bool?,
      data:
          json['data'] == null
              ? null
              : BusinessData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BusinessListModelToJson(BusinessListModel instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

BusinessData _$BusinessDataFromJson(Map<String, dynamic> json) => BusinessData(
  summary:
      json['summary'] == null
          ? null
          : BusinessSummary.fromJson(json['summary'] as Map<String, dynamic>),
  businesses:
      (json['businesses'] as List<dynamic>?)
          ?.map((e) => BusinessListData.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BusinessDataToJson(BusinessData instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'businesses': instance.businesses,
    };

BusinessSummary _$BusinessSummaryFromJson(Map<String, dynamic> json) =>
    BusinessSummary(
      targetAmount: _stringFromDynamic(json['target_amount']),
      totalBusiness: _stringFromDynamic(json['total_business']),
      totalCollected: _stringFromDynamic(json['total_collected']),
      percentage: _stringFromDynamic(json['percentage']),
      pendingCount: _stringFromDynamic(json['pending_count']),
      completedCount: _stringFromDynamic(json['completed_count']),
      totalCount: _stringFromDynamic(json['total_count']),
      achievedStatus: _stringFromDynamic(json['achieved_status']),
    );

Map<String, dynamic> _$BusinessSummaryToJson(BusinessSummary instance) =>
    <String, dynamic>{
      'target_amount': instance.targetAmount,
      'total_business': instance.totalBusiness,
      'total_collected': instance.totalCollected,
      'percentage': instance.percentage,
      'pending_count': instance.pendingCount,
      'completed_count': instance.completedCount,
      'total_count': instance.totalCount,
      'achieved_status': instance.achievedStatus,
    };

BusinessListData _$BusinessListDataFromJson(
  Map<String, dynamic> json,
) => BusinessListData(
  businessId: _stringFromDynamic(json['business_id']),
  businessName: _stringFromDynamic(json['business_name']),
  clientName: _stringFromDynamic(json['client_name']),
  collectionPendingStatus: _stringFromDynamic(
    json['collection_pending_status'],
  ),
  totalBusinessCost: _stringFromDynamic(json['total_business_cost']),
  collectedBusinessCost: _stringFromDynamic(json['collected_business_cost']),
  pendingCollection: _stringFromDynamic(json['pending_collection']),
  createdAt: _stringFromDynamic(json['created_at']),
  collectedPayments:
      (json['collected_payments'] as List<dynamic>?)
          ?.map(
            (e) => CollectedPaymentsList.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$BusinessListDataToJson(BusinessListData instance) =>
    <String, dynamic>{
      'business_id': instance.businessId,
      'business_name': instance.businessName,
      'client_name': instance.clientName,
      'collection_pending_status': instance.collectionPendingStatus,
      'total_business_cost': instance.totalBusinessCost,
      'collected_business_cost': instance.collectedBusinessCost,
      'pending_collection': instance.pendingCollection,
      'created_at': instance.createdAt,
      'collected_payments': instance.collectedPayments,
    };

CollectedPaymentsList _$CollectedPaymentsListFromJson(
  Map<String, dynamic> json,
) => CollectedPaymentsList(
  id: _stringFromDynamic(json['id']),
  amount: _stringFromDynamic(json['amount']),
  collecteDate: _stringFromDynamic(json['collected_date']),
);

Map<String, dynamic> _$CollectedPaymentsListToJson(
  CollectedPaymentsList instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'collected_date': instance.collecteDate,
};
