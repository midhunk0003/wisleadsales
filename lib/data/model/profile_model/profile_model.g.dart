// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  success: json['success'] as bool?,
  message: json['message'] as String?,
  data:
      json['data'] == null
          ? null
          : ProfileData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };

ProfileData _$ProfileDataFromJson(Map<String, dynamic> json) => ProfileData(
  id: (json['id'] as num?)?.toInt(),
  role: json['role'] as String?,
  name: json['name'] as String?,
  mobilePhone: json['mobile_phone'] as String?,
  email: json['email'] as String?,
  empId: json['emp_id'],
  isActive: _stringFromDynamic(json['isActive']),
  designation: json['designation'],
  branch: json['branch'],
  docVerified: json['doc_verified'] as bool?,
  profileImage: json['profile_image'] as String?,
  resume: json['resume'] as String?,
  addressProof: json['address_proof'] as String?,
  bankDetails:
      json['bank_details'] == null
          ? null
          : BankDetails.fromJson(json['bank_details'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileDataToJson(ProfileData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'name': instance.name,
      'mobile_phone': instance.mobilePhone,
      'email': instance.email,
      'emp_id': instance.empId,
      'isActive': instance.isActive,
      'designation': instance.designation,
      'branch': instance.branch,
      'doc_verified': instance.docVerified,
      'profile_image': instance.profileImage,
      'resume': instance.resume,
      'address_proof': instance.addressProof,
      'bank_details': instance.bankDetails,
    };

BankDetails _$BankDetailsFromJson(Map<String, dynamic> json) => BankDetails(
  bankName: json['bank_name'] as String?,
  accountNo: json['account_no'] as String?,
  ifscCode: json['ifsc_code'] as String?,
);

Map<String, dynamic> _$BankDetailsToJson(BankDetails instance) =>
    <String, dynamic>{
      'bank_name': instance.bankName,
      'account_no': instance.accountNo,
      'ifsc_code': instance.ifscCode,
    };
