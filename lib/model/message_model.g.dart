// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['uid'] as String,
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  message: json['message'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  mediaUrl: json['mediaUrl'] as String,
  timeStamp: MessageModel._fromJson(json['timeStamp']),
  status: $enumDecode(_$MessageStatusEnumMap, json['status']),
  reactions: json['reactions'] as Map<String, dynamic>,
  replyMessageId: json['replyMessageId'] as String,
  isDeleted: json['isDeleted'] as bool,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'uid': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'message': instance.message,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'mediaUrl': instance.mediaUrl,
      'timeStamp': MessageModel._toJson(instance.timeStamp),
      'status': _$MessageStatusEnumMap[instance.status]!,
      'reactions': instance.reactions,
      'replyMessageId': instance.replyMessageId,
      'isDeleted': instance.isDeleted,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.document: 'document',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.read: 'read',
};
