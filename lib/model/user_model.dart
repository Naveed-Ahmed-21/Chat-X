import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePic;
  final String about;
  final String createdAt;
  final String lastOnlineStatus;
  final String status;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePic,
    required this.about,
    required this.createdAt,
    required this.lastOnlineStatus,
    required this.status,
    this.isOnline = false,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePic,
    String? about,
    String? createdAt,
    String? lastOnlineStatus,
    String? status,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePic: profilePic ?? this.profilePic,
      about: about ?? this.about,
      createdAt: createdAt ?? this.createdAt,
      lastOnlineStatus: lastOnlineStatus ?? this.lastOnlineStatus,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? (json['email']?.toString().split('@').first ?? 'User'),
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      profilePic: json['profilePic']?.toString() ?? '',
      about: json['about']?.toString() ?? 'Hey there! I am using Chat X',
      createdAt: json['createdAt']?.toString() ?? '',
      lastOnlineStatus: json['lastOnlineStatus']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
