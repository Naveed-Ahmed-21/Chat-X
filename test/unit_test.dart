import 'package:flutter_test/flutter_test.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/model/chat_room_model.dart';
import 'package:chatx_app/widgets/message_status.dart';
import 'package:chatx_app/widgets/message_type.dart';
import 'package:chatx_app/utils/date_time_formatter.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        uid: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1234567890',
        profilePic: 'https://example.com/pic.jpg',
        about: 'Hello world',
        createdAt: '2026-01-01',
        lastOnlineStatus: 'online',
        status: 'Active',
      );

      final json = user.toJson();
      expect(json['uid'], '123');
      expect(json['name'], 'John Doe');

      final fromJsonUser = UserModel.fromJson(json);
      expect(fromJsonUser.uid, user.uid);
      expect(fromJsonUser.name, user.name);
      expect(fromJsonUser.email, user.email);
    });

    test('UserModel copyWith works correctly', () {
      final user = UserModel(
        uid: '123',
        name: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1234567890',
        profilePic: '',
        about: '',
        createdAt: '',
        lastOnlineStatus: 'offline',
        status: '',
      );

      final updated = user.copyWith(name: 'Jane Doe', lastOnlineStatus: 'online');
      expect(updated.uid, '123');
      expect(updated.name, 'Jane Doe');
      expect(updated.email, 'john@example.com');
      expect(updated.lastOnlineStatus, 'online');
    });
  });

  group('DateTimeFormatter Tests', () {
    test('formatTime handles null', () {
      expect(DateTimeFormatter.formatTime(null), '');
    });

    test('formatTime formats valid DateTime', () {
      final dt = DateTime(2026, 8, 16, 14, 30);
      expect(DateTimeFormatter.formatTime(dt), '2:30 PM');
    });

    test('formatChatDate handles null', () {
      expect(DateTimeFormatter.formatChatDate(null), '');
    });

    test('formatChatDate formats Today correctly', () {
      final now = DateTime.now();
      expect(DateTimeFormatter.formatChatDate(now), 'Today');
    });

    test('formatChatDate formats Yesterday correctly', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateTimeFormatter.formatChatDate(yesterday), 'Yesterday');
    });

    test('formatLastMessageTime handles null', () {
      expect(DateTimeFormatter.formatLastMessageTime(null), '');
    });

    test('formatOnline formats online status time', () {
      final dt = DateTime(2026, 8, 16, 10, 15);
      expect(DateTimeFormatter.formatOnline(dt), 'Online 10:15 AM');
    });

    test('formatSeen formats seen time', () {
      final dt = DateTime(2026, 8, 16, 10, 15);
      expect(DateTimeFormatter.formatSeen(dt), 'Seen 10:15 AM');
    });
  });

  group('MessageModel Tests', () {
    test('MessageModel serialization and deserialization', () {
      final msg = MessageModel(
        id: 'msg_1',
        senderId: 'user_a',
        receiverId: 'user_b',
        message: 'Hello!',
        type: MessageType.text,
        mediaUrl: '',
        status: MessageStatus.sent,
        reactions: {'user_b': '👍'},
        replyMessageId: '',
        isDeleted: false,
        fileName: '',
        duration: 0,
        thumbnail: '',
        extension: '',
        timeStamp: DateTime(2026, 8, 16, 12, 0),
      );

      final json = msg.toJson();
      expect(json['id'], 'msg_1');
      expect(json['type'], MessageType.text.name);
      expect(json['status'], MessageStatus.sent.name);

      final fromJsonMsg = MessageModel.fromJson(json);
      expect(fromJsonMsg.id, 'msg_1');
      expect(fromJsonMsg.senderId, 'user_a');
      expect(fromJsonMsg.type, MessageType.text);
      expect(fromJsonMsg.status, MessageStatus.sent);
    });
  });

  group('ChatRoomModel Tests', () {
    test('ChatRoomModel serialization and deserialization', () {
      final room = ChatRoomModel(
        id: 'user_a_user_b',
        participants: ['user_a', 'user_b'],
        lastMessage: 'Hey there',
        lastMessageSenderId: 'user_a',
        isGroup: false,
      );

      final json = room.toJson();
      expect(json['id'], 'user_a_user_b');
      expect(json['lastMessage'], 'Hey there');

      final fromJsonRoom = ChatRoomModel.fromJson(json);
      expect(fromJsonRoom.id, 'user_a_user_b');
      expect(fromJsonRoom.participants, containsAll(['user_a', 'user_b']));
    });
  });
}
