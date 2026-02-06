import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  bool? success;
  String? message;
  String? token;
  User? user;
  @JsonKey(name: 'profile_image')
  String? profileImage;

  LoginModel({
    this.success,
    this.message,
    this.token,
    this.user,
    this.profileImage,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return _$LoginModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}

@JsonSerializable()
class User {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  dynamic photo;
  @JsonKey(name: 'fcm_token')
  String? fcmToken;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.photo,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
