import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GroupModel {
  final String id;

  final String name;

  final String image;

  final String createdBy;

  final List<String> members;

  final List<String> admins;

  final String lastMessage;

  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime? updatedAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.image,
    required this.createdBy,
    required this.members,
    required this.admins,
    required this.lastMessage,
    this.updatedAt,
  });

  static DateTime? _fromJson(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.parse(value.toString());
  }

  static Timestamp? _toJson(DateTime? value) {
    if (value == null) return null;

    return Timestamp.fromDate(value);
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}
