import 'package:json_annotation/json_annotation.dart';

part 'call_follow_up_languages.g.dart';

String? _stringFromDynamic(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class CallFollowUpLanguages {
  bool? success;
  List<CallLanguage>? data;

  CallFollowUpLanguages({this.success, this.data});

  factory CallFollowUpLanguages.fromJson(Map<String, dynamic> json) {
    return _$CallFollowUpLanguagesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallFollowUpLanguagesToJson(this);
}

@JsonSerializable()
class CallLanguage {
  @JsonKey(fromJson: _stringFromDynamic)
  String? id;
  @JsonKey(fromJson: _stringFromDynamic)
  String? name;
  @JsonKey(fromJson: _stringFromDynamic)
  String? status;
  @JsonKey(name: 'created_at', fromJson: _stringFromDynamic)
  String? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _stringFromDynamic)
  String? updatedAt;

  CallLanguage({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CallLanguage.fromJson(Map<String, dynamic> json) =>
      _$CallLanguageFromJson(json);

  Map<String, dynamic> toJson() => _$CallLanguageToJson(this);
}
