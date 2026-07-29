
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/chat_type.dart';
import 'package:chatx_app/utils/date_time_formatter.dart';
import 'package:flutter/material.dart';

class MessagePreviewBubble extends StatelessWidget {
  final MessageModel message;
  final bool isComing;
  final MessageModel? repliedMessage;
  final String repliedSenderName;

  const MessagePreviewBubble({
    super.key,
    required this.message,
    required this.isComing,
    this.repliedMessage,
    this.repliedSenderName = "",
  });

  @override
  Widget build(BuildContext context) {
    return ChatType(
      message: message.message,
      type: message.type,
      imageUrl: message.mediaUrl,
      thumbnail: message.thumbnail,
      isComing: isComing,
      time: DateTimeFormatter.formatTime(message.timeStamp),
      status: message.status,
      repliedMessage: repliedMessage,
      repliedSenderName: repliedSenderName,
      isDeleted: message.isDeleted,
      isEdited: message.isEdited,
      reactions: message.reactions,
      heroTag: "preview_${message.id}",
      imageMessages: const [],
      currentImageIndex: -1,
      messageModel: message,
      enableHero: false,
    );
  }
}
