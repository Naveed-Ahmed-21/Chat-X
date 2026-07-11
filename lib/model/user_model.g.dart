// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['uid'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  profilePic: json['profilePic'] as String,
  about: json['about'] as String,
  createdAt: json['createdAt'] as String,
  lastOnlineStatus: json['lastOnlineStatus'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'profilePic': instance.profilePic,
  'about': instance.about,
  'createdAt': instance.createdAt,
  'lastOnlineStatus': instance.lastOnlineStatus,
  'status': instance.status,
};
