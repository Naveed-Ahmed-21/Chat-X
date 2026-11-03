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
  groupDescription: json['groupDescription'] as String? ?? '',
  typingStatus:
      (json['typingStatus'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  pinnedBy:
      (json['pinnedBy'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  nicknames:
      (json['nicknames'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  deletedFor:
      (json['deletedFor'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      {},
  clearChatAt: json['clearChatAt'] == null
      ? const {}
      : ChatRoomModel._lastReadFromJson(
          json['clearChatAt'] as Map<String, dynamic>?,
        ),
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
  'groupDescription': instance.groupDescription,
  'typingStatus': instance.typingStatus,
  'pinnedBy': instance.pinnedBy,
  'nicknames': instance.nicknames,
  'deletedFor': instance.deletedFor,
  'clearChatAt': ChatRoomModel._lastReadToJson(instance.clearChatAt),
  'createdAt': ChatRoomModel._toJson(instance.createdAt),
};
