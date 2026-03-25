import 'package:json_annotation/json_annotation.dart';

part 'call_follow_up_note_model.g.dart';

String? _stringFromDynamic(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

@JsonSerializable()
class CallFollowUpNoteModel {
  bool? success;
  List<CallNote>? data;

  CallFollowUpNoteModel({this.success, this.data});

  factory CallFollowUpNoteModel.fromJson(Map<String, dynamic> json) {
    return _$CallFollowUpNoteModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CallFollowUpNoteModelToJson(this);
}

@JsonSerializable()
class CallNote {
  @JsonKey(fromJson: _stringFromDynamic)
  String? id;
  @JsonKey(fromJson: _stringFromDynamic)
  String? title;
  @JsonKey(fromJson: _stringFromDynamic)
  String? status;
  @JsonKey(name: 'created_at', fromJson: _stringFromDynamic)
  String? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _stringFromDynamic)
  String? updatedAt;

  CallNote({this.id, this.title, this.status, this.createdAt, this.updatedAt});

  factory CallNote.fromJson(Map<String, dynamic> json) =>
      _$CallNoteFromJson(json);

  Map<String, dynamic> toJson() => _$CallNoteToJson(this);
}
