// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  image: json['image'] as String,
  createdBy: json['createdBy'] as String,
  members: (json['members'] as List<dynamic>).map((e) => e as String).toList(),
  admins: (json['admins'] as List<dynamic>).map((e) => e as String).toList(),
  lastMessage: json['lastMessage'] as String,
  updatedAt: GroupModel._fromJson(json['updatedAt']),
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'createdBy': instance.createdBy,
      'members': instance.members,
      'admins': instance.admins,
      'lastMessage': instance.lastMessage,
      'updatedAt': GroupModel._toJson(instance.updatedAt),
    };
