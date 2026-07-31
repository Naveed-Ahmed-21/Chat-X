// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  receiverId: json['receiverId'] as String,
  message: json['message'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  mediaUrl: json['mediaUrl'] as String,
  localPath: json['localPath'] as String? ?? '',
  timeStamp: MessageModel._fromJson(json['timeStamp']),
  status: MessageModel._statusFromJson(json['status'] as String),
  reactions: json['reactions'] as Map<String, dynamic>,
  replyMessageId: json['replyMessageId'] as String,
  isDeleted: json['isDeleted'] as bool,
  deletedFor: json['deletedFor'] as Map<String, dynamic>? ?? const {},
  isEdited: json['isEdited'] as bool? ?? false,
  fileName: json['fileName'] as String? ?? '',
  fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  thumbnail: json['thumbnail'] as String? ?? '',
  extension: json['extension'] as String? ?? '',
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'message': instance.message,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'mediaUrl': instance.mediaUrl,
      'localPath': instance.localPath,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'thumbnail': instance.thumbnail,
      'duration': instance.duration,
      'extension': instance.extension,
      'timeStamp': MessageModel._toJson(instance.timeStamp),
      'status': MessageModel._statusToJson(instance.status),
      'reactions': instance.reactions,
      'replyMessageId': instance.replyMessageId,
      'isDeleted': instance.isDeleted,
      'deletedFor': instance.deletedFor,
      'isEdited': instance.isEdited,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.file: 'file',
};
