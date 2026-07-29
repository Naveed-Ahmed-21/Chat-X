import 'package:chatx_app/model/message_model.dart';
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
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.3,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: isComing
              ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(12),
          )
              : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            /// Reply Preview
            if (repliedMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repliedSenderName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      repliedMessage!.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

            /// Image
            if (message.mediaUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  message.mediaUrl,
                  width: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image, size: 100),
                ),
              ),

            if (message.mediaUrl.isNotEmpty &&
                message.message.isNotEmpty)
              const SizedBox(height: 10),

            /// Deleted Message
            if (message.isDeleted)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.block,
                    color: Colors.grey,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "This message was deleted",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )

            /// Normal Message
            else if (message.message.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message.message,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (message.isEdited)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Text(
                        "(edited)",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}