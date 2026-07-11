import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../widgets/message_status.dart';
import '../widgets/message_type.dart';

part 'message_model.g.dart';

@JsonSerializable(explicitToJson: true)

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final MessageType type;
  final String mediaUrl;

  @JsonKey(
    fromJson: _fromJson,
    toJson: _toJson,
  )
  final DateTime? timeStamp;
  final MessageStatus status;
  final Map<String, dynamic> reactions;
  final String replyMessageId;
  final bool isDeleted;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    required this.mediaUrl,
    this.timeStamp,
    required this.status,
    required this.reactions,
    required this.replyMessageId,
    required this.isDeleted,
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

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MessageModelToJson(this);

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    MessageType? type,
    String? mediaUrl,
    DateTime? timeStamp,
    MessageStatus? status,
    Map<String, dynamic>? reactions,
    String? replyMessageId,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timeStamp: timeStamp ?? this.timeStamp,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      replyMessageId: replyMessageId ?? this.replyMessageId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}