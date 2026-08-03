// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoomModel _$ChatRoomModelFromJson(
  Map<String, dynamic> json,
) => ChatRoomModel(
  id: json['id'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMessage: json['lastMessage'] as String? ?? "",
  lastMessageSenderId: json['lastMessageSenderId'] as String? ?? "",
  lastMessageTimestamp: ChatRoomModel._fromJson(json['lastMessageTimestamp']),
  lastReadTimestamp: json['lastReadTimestamp'] == null
      ? const {}
      : ChatRoomModel._lastReadFromJson(
          json['lastReadTimestamp'] as Map<String, dynamic>?,
        ),
  isGroup: json['isGroup'] as bool? ?? false,
  groupName: json['groupName'] as String? ?? "",
  createdAt: ChatRoomModel._fromJson(json['createdAt']),
  groupImage: json['groupImage'] as String? ?? '',
  createdBy: json['createdBy'] as String? ?? '',
  admins:
      (json['admins'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$ChatRoomModelToJson(
  ChatRoomModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'participants': instance.participants,
  'lastMessage': instance.lastMessage,
  'lastMessageSenderId': instance.lastMessageSenderId,
  'groupImage': instance.groupImage,
  'createdBy': instance.createdBy,
  'admins': instance.admins,
  'lastMessageTimestamp': ChatRoomModel._toJson(instance.lastMessageTimestamp),
  'lastReadTimestamp': ChatRoomModel._lastReadToJson(
    instance.lastReadTimestamp,
  ),
  'isGroup': instance.isGroup,
  'groupName': instance.groupName,
  'createdAt': ChatRoomModel._toJson(instance.createdAt),
};
