import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_room_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatRoomModel {

  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSenderId;

  @JsonKey(
    fromJson: _fromJson,
    toJson: _toJson,
  )
  final DateTime? lastMessageTimestamp;

  @JsonKey(
    fromJson: _lastReadFromJson,
    toJson: _lastReadToJson,
  )
  final Map<String, DateTime> lastReadTimestamp;
  final bool isGroup;
  final String groupName;
  @JsonKey(
    fromJson: _fromJson,
    toJson: _toJson,
  )
  final DateTime? createdAt;

  const ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage = "",
    this.lastMessageSenderId = "",
    this.lastMessageTimestamp,
    this.lastReadTimestamp = const {},
    this.isGroup = false,
    this.groupName = "",
    this.createdAt,
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

  static Map<String, DateTime> _lastReadFromJson(
      Map<String, dynamic>? json) {
    if (json == null) return {};

    return json.map(
          (key, value) => MapEntry(
        key,
        (value as Timestamp).toDate(),
      ),
    );
  }

  static Map<String, Timestamp> _lastReadToJson(
      Map<String, DateTime>? map) {
    if (map == null) return {};

    return map.map(
          (key, value) => MapEntry(
        key,
        Timestamp.fromDate(value),
      ),
    );
  }

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ChatRoomModelToJson(this);

  ChatRoomModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTimestamp,
    Map<String, DateTime>? lastReadTimestamp,
    bool? isGroup,
    String? groupName,
    DateTime? createdAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId:
      lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTimestamp:
      lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastReadTimestamp:
      lastReadTimestamp ?? this.lastReadTimestamp,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}