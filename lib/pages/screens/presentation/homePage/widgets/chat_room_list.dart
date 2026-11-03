import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:chatx_app/model/chat_room_model.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/chat_screen.dart';
import 'package:chatx_app/pages/screens/presentation/homePage/widgets/chat_tile.dart';
import 'package:chatx_app/utils/date_time_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../../../controller/chat_controller.dart';

class ChatRoomList extends StatelessWidget {
  final String searchQuery;
  final bool onlyGroups;
  ChatRoomList({super.key, this.searchQuery = "", this.onlyGroups = false});

  final ChatRoomController roomController = Get.find<ChatRoomController>();
  final ChatController chatController = Get.find<ChatController>();
  final UserContactController userController =
      Get.find<UserContactController>();

  Future<int> _getUnreadCount(ChatRoomModel room) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return 0;

    if (room.isGroup) {
      final lastRead = room.lastReadTimestamp[currentUid] ?? DateTime(2000);
      final query = await FirebaseFirestore.instance
          .collection("chats")
          .doc(room.id)
          .collection("messages")
          .where("timeStamp", isGreaterThan: Timestamp.fromDate(lastRead))
          .get();

      // Filter: Not sent by me AND I'm not in the seenBy list
      return query.docs.where((doc) {
        final data = doc.data();
        final seenBy = List<String>.from(data['seenBy'] ?? []);
        return data['senderId'] != currentUid && !seenBy.contains(currentUid);
      }).length;
    } else {
      final otherUid = room.participants.firstWhere((uid) => uid != currentUid);
      final query = await FirebaseFirestore.instance
          .collection("chats")
          .doc(room.id)
          .collection("messages")
          .where("senderId", isEqualTo: otherUid)
          // Limit to a reasonable number to avoid heavy fetch/permission issues
          .limit(50)
          .get();

      return query.docs.where((doc) => doc.data()['status'] != "seen").length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        roomController.refreshRooms();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: StreamBuilder<List<ChatRoomModel>>(
        stream: roomController.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      'Could not load conversations. Check your connection and Firestore access.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var rooms = snapshot.data ?? [];

          // Filter by group status
          rooms = rooms.where((room) => room.isGroup == onlyGroups).toList();

          // Simple filtering logic
          if (searchQuery.isNotEmpty) {
            rooms = rooms.where((room) {
              if (room.isGroup) {
                return room.groupName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
              } else {
                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                if (currentUid == null) return false;
                final otherUserId = room.participants.firstWhereOrNull(
                  (uid) => uid != currentUid,
                );
                if (otherUserId == null) return false;
                final otherUser = userController.userList.firstWhereOrNull(
                  (u) => u.uid == otherUserId,
                );
                return otherUser?.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false;
              }
            }).toList();
          }

          if (rooms.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.appLogo, scale: 2),
                        const SizedBox(height: 20),
                        Text(
                          searchQuery.isNotEmpty
                              ? "No chats found matching your search"
                              : (onlyGroups
                                    ? "No groups yet"
                                    : "No conversations yet"),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              roomController.refreshRooms();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              scrollCacheExtent: const ScrollCacheExtent.pixels(500.0),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final currentUid = FirebaseAuth.instance.currentUser!.uid;
                final nickname = room.nicknames[currentUid] ?? "";

                if (room.isGroup) {
                  return FutureBuilder<int>(
                    future: _getUnreadCount(room),
                    initialData: 0,
                    builder: (context, unreadSnap) {
                      return InkWell(
                        onTap: () {
                          Get.to(
                            () => ChatScreen(
                              key: ValueKey(room.id),
                              chatRoom: room,
                            ),
                          );
                        },
                        onLongPress: () =>
                            _showChatOptions(context, room, room.groupName),
                        child: ChatTile(
                          heroTag: "group_chat_${room.id}",
                          imageUrl: room.groupImage,
                          name: nickname.isNotEmpty ? nickname : room.groupName,
                          lastMessage: room.lastMessage,
                          unreadCount: unreadSnap.data ?? 0,
                          lastTime: DateTimeFormatter.formatLastMessageTime(
                            room.lastMessageTimestamp,
                          ),
                          isOnline: false,
                          isGroup: true,
                        ),
                      );
                    }
                  );
                }

                final otherUserId = room.participants.firstWhereOrNull(
                  (uid) => uid != currentUid,
                );
                if (otherUserId == null) {
                  return _buildFallbackChatTile(context, room, nickname);
                }

                return Obx(() {
                  final user = userController.userList.firstWhereOrNull(
                    (u) => u.uid == otherUserId,
                  );

                  if (user == null) {
                    return FutureBuilder<UserModel?>(
                      future: userController.getUserById(otherUserId),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person_outline)),
                            title: Text('Loading conversation…'),
                          );
                        }
                        if (snap.data == null) {
                          return _buildFallbackChatTile(
                            context,
                            room,
                            nickname,
                            fallbackName: 'Chat',
                          );
                        }
                        return _buildChatTile(
                          context,
                          room,
                          snap.data!,
                          nickname,
                        );
                      },
                    );
                  }

                  return _buildChatTile(context, room, user, nickname);
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _showChatOptions(
    BuildContext context,
    ChatRoomModel room,
    String defaultName,
  ) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isPinned = room.pinnedBy.contains(currentUid);

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF212338),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: Colors.white70,
                ),
                title: Text(
                  isPinned ? "Unpin chat" : "Pin chat",
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  roomController.pinChat(room.id, !isPinned);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.white70),
                title: const Text(
                  "Add nickname",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  _showNicknameDialog(context, room, defaultName);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Delete chat",
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Get.back();
                  _showDeleteConfirm(room.id);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showNicknameDialog(
    BuildContext context,
    ChatRoomModel room,
    String defaultName,
  ) {
    final controller = TextEditingController(
      text: room.nicknames[FirebaseAuth.instance.currentUser!.uid] ?? "",
    );
    Get.defaultDialog(
      backgroundColor: const Color(0xFF212338),
      title: "Add Nickname",
      titleStyle: const TextStyle(color: Colors.white),
      content: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Enter nickname for $defaultName",
          hintStyle: const TextStyle(color: Colors.white54),
        ),
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      onConfirm: () {
        roomController.setNickname(room.id, controller.text.trim());
        Get.back();
      },
    );
  }

  void _showDeleteConfirm(String roomId) {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF212338),
      title: "Delete Chat?",
      titleStyle: const TextStyle(color: Colors.white),
      middleText:
          "This will remove the chat from your list. Other participants will still see it.",
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      textCancel: "Cancel",
      onConfirm: () {
        roomController.deleteChatForMe(roomId);
        Get.back();
      },
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    ChatRoomModel room,
    UserModel user,
    String nickname,
  ) {
    return FutureBuilder<int>(
      future: _getUnreadCount(room),
      initialData: 0,
      builder: (context, unreadSnap) {
        return InkWell(
          onTap: () {
            Get.to(
              () => ChatScreen(
                key: ValueKey(user.uid),
                user: user,
                chatRoom: room,
              ),
            );
          },
          onLongPress: () => _showChatOptions(context, room, user.name),
          child: ChatTile(
            heroTag: "direct_chat_${room.id}",
            imageUrl: user.profilePic,
            name: nickname.isNotEmpty ? nickname : user.name,
            lastMessage: room.lastMessage,
            unreadCount: unreadSnap.data ?? 0,
            lastTime: DateTimeFormatter.formatLastMessageTime(
              room.lastMessageTimestamp,
            ),
            isOnline: user.isOnline,
          ),
        );
      },
    );
  }

  Widget _buildFallbackChatTile(
    BuildContext context,
    ChatRoomModel room,
    String nickname, {
    String fallbackName = 'Chat',
  }) {
    final displayName = nickname.isNotEmpty ? nickname : fallbackName;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final otherUserId = room.participants.firstWhereOrNull(
          (uid) => uid != currentUid,
        ) ??
        room.id;
    final fallbackUser = UserModel(
      uid: otherUserId,
      name: displayName,
      email: '',
      phoneNumber: '',
      profilePic: '',
      about: '',
      createdAt: '',
      lastOnlineStatus: '',
      status: '',
    );

    return InkWell(
      onTap: () {
        Get.to(
          () => ChatScreen(
            key: ValueKey(room.id),
            user: fallbackUser,
            chatRoom: room,
          ),
        );
      },
      onLongPress: () => _showChatOptions(context, room, displayName),
      child: ChatTile(
        heroTag: 'direct_chat_${room.id}',
        imageUrl: '',
        name: displayName,
        lastMessage: room.lastMessage,
        unreadCount: 0,
        lastTime: DateTimeFormatter.formatLastMessageTime(
          room.lastMessageTimestamp,
        ),
        isOnline: false,
      ),
    );
  }
}
