import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/chat_type.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/empty_chat_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../controller/chat_controller.dart';
import '../../../../model/message_model.dart';
import '../../../../utils/date_time_formatter.dart';
import '../../../../widgets/message_status.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRoomController chatRoomController = Get.find<ChatRoomController>();
  final ChatController chatController = Get.find();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  TextEditingController messageController = TextEditingController();
  late final roomId = chatRoomController.getRoomId(widget.user.uid);

  int previousMessageCount = 0;

  final RxBool hasText = false.obs;
  bool hasInitialScroll = false;

  bool isAtBottom = true;

  @override
  void initState() {
    super.initState();

    messageController.addListener(() {
      hasText.value = messageController.text.trim().isNotEmpty;
    });

    chatController.markMessagesAsDelivered();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void scrollToLastMessage(int count) {
    if (!itemScrollController.isAttached) return;

    itemScrollController.scrollTo(
      index: count - 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomId = chatRoomController.getRoomId(widget.user.uid);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.toNamed('/userProfileScreen', arguments: widget.user);
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: widget.user.profilePic.isNotEmpty
                    ? NetworkImage(widget.user.profilePic)
                    : null,
                child: widget.user.profilePic.isEmpty
                    ? Image.asset(AppImages.male)
                    : const Icon(Icons.person),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    widget.user.status,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.call, color: Colors.grey[200]),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.videocam_rounded, color: Colors.grey[200]),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: SizedBox(
                child: Icon(Icons.emoji_emotions_outlined, size: 25),
              ),
            ),

            Expanded(
              child: TextField(
                controller: messageController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 2,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: "Type message....",
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            SizedBox(width: 5),

            InkWell(
              onTap: () {},
              child: SizedBox(
                height: 30,
                width: 30,
                child: Icon(Icons.photo_library_rounded, size: 25),
              ),
            ),

            SizedBox(width: 5),

            Obx(() {
              return hasText.value
                  ? InkWell(
                      onTap: () async {
                        final text = messageController.text.trim();
                        if (text.isEmpty) return;

                        messageController.clear();

                        await chatController.sendTextMessage(
                          receiverId: widget.user.uid,
                          text: text,
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        // Record voice
                      },
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(Icons.mic, size: 25),
                      ),
                    );
            }),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 70,
          top: 10,
          left: 10,
          right: 10,
        ),

        child: StreamBuilder<List<MessageModel>>(
          stream: chatController.getMessages(roomId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const EmptyChatWidget();
            }

            final messages = snapshot.data!;
            final lastMessage = messages.last;
            final currentUser = FirebaseAuth.instance.currentUser!.uid;
            final firstUnreadIndex = messages.indexWhere(
              (m) =>
                  m.receiverId == currentUser && m.status != MessageStatus.seen,
            );

            if (lastMessage.senderId ==
                    FirebaseAuth.instance.currentUser!.uid &&
                messages.length > previousMessageCount) {
              previousMessageCount = messages.length;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                scrollToLastMessage(messages.length);
              });
            }

            if (!hasInitialScroll) {
              hasInitialScroll = true;

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!itemScrollController.isAttached) return;

                if (firstUnreadIndex != -1) {
                  // Show a few old messages above the first unread one
                  final targetIndex = (firstUnreadIndex - 4).clamp(
                    0,
                    messages.length - 1,
                  );

                  itemScrollController.jumpTo(index: targetIndex);
                } else {
                  // No unread messages, open at the latest message
                  itemScrollController.jumpTo(index: messages.length - 1);
                }

                // Wait for the scroll to finish
                await Future.delayed(const Duration(milliseconds: 500));

                // Now mark them as seen
                chatController.markMessagesAsSeen(roomId, widget.user.uid);
              });
            }

            return ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Column(
                  children: [
                    if (index == firstUnreadIndex)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Unread Messages",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ChatType(
                      message: message.message,
                      imageUrl: message.mediaUrl,
                      isComing:
                          message.senderId !=
                          FirebaseAuth.instance.currentUser!.uid,
                      time: DateTimeFormatter.formatTime(message.timeStamp),
                      status: message.status,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
