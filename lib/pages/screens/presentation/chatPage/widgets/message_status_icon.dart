import 'package:flutter/material.dart';
import '../../../../../widgets/message_status.dart';

class MessageStatusIcon extends StatelessWidget {
  final MessageStatus status;

  const MessageStatusIcon({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return const Icon(
          Icons.schedule,
          size: 16,
        );

      case MessageStatus.sent:
        return const Icon(
          Icons.done,
          size: 16,
        );

      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.grey,
        );

      case MessageStatus.seen:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: Colors.blue,
        );
    }
  }
}