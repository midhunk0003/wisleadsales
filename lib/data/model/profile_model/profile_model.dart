import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

String? _stringFromDynamic(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class ProfileModel {
  bool? success;
  String? message;
  ProfileData? data;

  ProfileModel({this.success, this.message, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return _$ProfileModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable()
class ProfileData {
  int? id;
  String? role;
  String? name;
  @JsonKey(name: 'mobile_phone')
  String? mobilePhone;
  String? email;
  @JsonKey(name: 'emp_id')
  dynamic empId;
  @JsonKey(fromJson: _stringFromDynamic)
  String? isActive;
  dynamic designation;
  dynamic branch;
  @JsonKey(name: 'doc_verified')
  bool? docVerified;
  @JsonKey(name: 'profile_image')
  String? profileImage;
  String? resume;
  @JsonKey(name: 'address_proof')
  String? addressProof;
  @JsonKey(name: 'bank_details')
  BankDetails? bankDetails;

  ProfileData({
    this.id,
    this.role,
    this.name,
    this.mobilePhone,
    this.email,
    this.empId,
    this.isActive,
    this.designation,
    this.branch,
    this.docVerified,
    this.profileImage,
    this.resume,
    this.addressProof,
    this.bankDetails,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}

@JsonSerializable()
class BankDetails {
  @JsonKey(name: 'bank_name')
  String? bankName;

  @JsonKey(name: 'account_no')
  String? accountNo;

  @JsonKey(name: 'ifsc_code')
  String? ifscCode;

  BankDetails({this.bankName, this.accountNo, this.ifscCode});

  factory BankDetails.fromJson(Map<String, dynamic> json) =>
      _$BankDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BankDetailsToJson(this);
}
