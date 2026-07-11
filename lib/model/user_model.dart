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
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
