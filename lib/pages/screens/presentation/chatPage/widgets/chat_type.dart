import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/message_status_icon.dart';
import 'package:chatx_app/widgets/message_status.dart';
import 'package:flutter/material.dart';


class ChatType extends StatelessWidget {
  final String message;
  final String imageUrl;
  final bool isComing;
  final String time;
  final MessageStatus status;
  final MessageModel? repliedMessage;
  final String repliedSenderName;
  final bool isDeleted;
  final bool isEdited;
  final Map<String, dynamic> reactions;

  const ChatType({
    super.key,
    required this.message,
    required this.imageUrl,
    required this.isComing,
    required this.time,
    required this.status,
    this.repliedMessage,
    this.repliedSenderName = "",
    required this.isDeleted,
    required this.isEdited,
    required this.reactions,
  });

  @override
  Widget build(BuildContext context) {

    Widget buildReactionBubble(BuildContext context) {

      final grouped = <String, int>{};

      for (final emoji in reactions.values) {
        grouped[emoji] = (grouped[emoji] ?? 0) + 1;
      }

      return Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white10,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: grouped.entries.map((entry) {

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 17),
                    ),

                    if (entry.value > 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              );

            }).toList(),
          ),
        ),
      );
    }


    return Padding(
      padding: const EdgeInsets.only(top:4,bottom: 2),
      child: Column(
        crossAxisAlignment: isComing
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          // AnimatedContainer(
          //   duration: const Duration(milliseconds: 200),
          //   transform: Matrix4.identity(),
          //
          //   child:
            Container(
              padding: EdgeInsets.all(10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width / 1.3,
              ),
              decoration: BoxDecoration(
                borderRadius: isComing
                    ? BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(10),
                      )
                    : BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(0),
                      ),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: isComing
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (repliedMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
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

                          const SizedBox(height: 2),

                          Text(
                            repliedMessage!.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  if (imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
                        width: 250,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            size: 100,
                          );
                        },
                      ),
                    ),

                  if (imageUrl.isNotEmpty) const SizedBox(height: 10),

                  if (isDeleted)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.block, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          "This message was deleted",
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  else if (message.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: Text(message)),

                        if (isEdited)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
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
          // ),

          if (reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 3,
                bottom: 3,
              ),
              child: Align(
                alignment: isComing
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: buildReactionBubble(context),
              ),
            ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: isComing
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              isComing
                  ? Text(time, style: Theme.of(context).textTheme.labelMedium)
                  : Row(
                      children: [
                        Text(
                          time,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        if (!isComing) MessageStatusIcon(status: status),
                      ],
                    ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
