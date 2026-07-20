import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/chat_type.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/date_separator.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/empty_chat_widget.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/message_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../controller/chat_controller.dart';
import '../../../../model/message_model.dart';
import '../../../../services/upload_service.dart';
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
  final ImagePicker picker = ImagePicker();
  final UploadService uploadService = UploadService();
  TextEditingController messageController = TextEditingController();

  final FocusNode messageFocus = FocusNode();
  late final roomId = chatRoomController.getRoomId(widget.user.uid);
  late final Stream<List<MessageModel>> messageStream;
  final RxString selectedMessageId = "".obs;

  int previousMessageCount = 0;

  final RxBool hasText = false.obs;
  bool hasInitialScroll = false;
  bool isAtBottom = true;

  @override
  void initState() {
    super.initState();

    messageStream = chatController.getMessages(roomId);

    messageController.addListener(() {
      hasText.value = messageController.text.trim().isNotEmpty;
    });

    chatController.markMessagesAsDelivered();
  }

  @override
  void dispose() {
    messageController.dispose();
    MessageOverlay.hide();
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

  void showDeleteConfirmation(MessageModel message, bool isComing) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete message?"),
        content: const Text("Choose how you want to delete this message."),
        actions: [
          TextButton(
            onPressed: () async {
              Get.back();

              await chatController.deleteForMe(
                roomId: roomId,
                messageId: message.id,
              );
            },
            child: const Text("Delete for me"),
          ),

          if (!isComing)
            TextButton(
              onPressed: () async {
                Get.back();

                await chatController.deleteForEveryone(
                  roomId: roomId,
                  messageId: message.id,
                );
              },
              child: const Text(
                "Delete for everyone",
                style: TextStyle(color: Colors.red),
              ),
            ),

          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ],
      ),
    );
  }

  void showEditDialog(MessageModel message) {
    final controller = TextEditingController(text: message.message);

    Get.defaultDialog(
      title: "Edit Message",
      content: TextField(controller: controller, maxLines: 4),
      textCancel: "Cancel",
      textConfirm: "Save",
      onConfirm: () async {
        final text = controller.text.trim();

        if (text.isEmpty) return;

        Get.back();

        await chatController.editMessage(
          roomId: roomId,
          messageId: message.id,
          newMessage: text,
        );
      },
    );
  }

  Widget buildMessageComposer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Reply Preview
          Obx(() {
            final reply = chatController.replyingMessage.value;

            if (reply == null) return const SizedBox();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Replying to",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          reply.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: chatController.cancelReply,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            );
          }),

          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.emoji_emotions_outlined),
              ),

              Expanded(
                child: TextField(
                  controller: messageController,
                  focusNode: messageFocus,
                  minLines: 1,
                  maxLines: 4,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: "Type message...",
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),

              IconButton(
                onPressed: showMediaPicker,
                icon: const Icon(Icons.photo_library_rounded),
              ),

              Obx(() {
                return hasText.value
                    ? IconButton(
                        onPressed: () async {
                          final text = messageController.text.trim();

                          if (text.isEmpty) return;

                          messageController.clear();

                          await chatController.sendTextMessage(
                            receiverId: widget.user.uid,
                            text: text,
                          );
                        },
                        icon: Icon(
                          Icons.send_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : IconButton(onPressed: () {}, icon: const Icon(Icons.mic));
              }),
            ],
          ),
        ],
      ),
    );
  }

  void showMediaPicker() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
          child: Wrap(
            children: [

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.gallery);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (file == null) return;

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final imageUrl = await uploadService.uploadImage(file.path);

      Get.back();

      if (imageUrl == "") {
        Get.snackbar(
          "Upload Failed",
          "Unable to upload image",
        );
        return;
      }

      await chatController.sendImageMessage(
        receiverId: widget.user.uid,
        imageUrl: imageUrl,
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              //bottom: 5,
              top: 10,
              left: 10,
              right: 10,
            ),

            child: StreamBuilder<List<MessageModel>>(
              stream: messageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print(snapshot.error);

                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const EmptyChatWidget();
                }

                final messages = snapshot.data!;
                final lastMessage = messages.last;
                final currentUser = FirebaseAuth.instance.currentUser!.uid;
                final firstUnreadIndex = messages.indexWhere(
                  (m) =>
                      m.receiverId == currentUser &&
                      m.status != MessageStatus.seen,
                );

                if (lastMessage.senderId ==
                        FirebaseAuth.instance.currentUser!.uid &&
                    messages.length > previousMessageCount) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (messages.length > previousMessageCount) {
                      previousMessageCount = messages.length;
                      scrollToLastMessage(messages.length);
                    }
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

                return Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: ScrollablePositionedList.builder(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      
                      // Use a ValueKey to help Flutter track items correctly and avoid GlobalKey conflicts
                      final itemKey = ValueKey(message.id);

                      MessageModel? repliedMessage;

                      if (message.replyMessageId.isNotEmpty) {
                        try {
                          repliedMessage = messages.firstWhere(
                            (m) => m.id == message.replyMessageId,
                          );
                        } catch (_) {
                          repliedMessage = null;
                        }
                      }

                      final isComing =
                          message.senderId !=
                          FirebaseAuth.instance.currentUser!.uid;

                      final repliedSenderName = repliedMessage == null
                          ? ""
                          : repliedMessage.senderId ==
                                FirebaseAuth.instance.currentUser!.uid
                          ? "You"
                          : widget.user.name;

                      bool showDate = false;
                      if (index == 0) {
                        showDate = true;
                      } else {
                        final previous = messages[index - 1];

                        showDate =
                            DateTimeFormatter.chatDate(previous.timeStamp) !=
                            DateTimeFormatter.chatDate(message.timeStamp);
                      }

                      return Column(
                        key: itemKey,
                        children: [
                          if (showDate)
                            DateSeparator(
                              text: DateTimeFormatter.chatDate(
                                message.timeStamp,
                              ),
                            ),
                          if (index == firstUnreadIndex)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
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

                          Builder(builder: (messageContext) {
                            return GestureDetector(
                              onLongPress: () {
                                MessageOverlay.show(
                                  context: context,
                                  messageContext: messageContext,
                            
                                  message: message,
                                  isComing: isComing,
                            
                                  repliedMessage: repliedMessage,
                                  repliedSenderName: repliedSenderName,
                            
                                  showEdit: !isComing,
                            
                                  onReaction: (emoji) async {
                                    await chatController.reactToMessage(
                                      roomId: roomId,
                                      messageId: message.id,
                                      emoji: emoji,
                                      reactions: message.reactions,
                                    );
                                  },
                            
                                  onReply: () {
                                    chatController.startReply(message);
                                    messageFocus.requestFocus();
                                  },
                            
                                  onCopy: () async {
                                    await Clipboard.setData(
                                      ClipboardData(text: message.message),
                                    );
                            
                                    Get.snackbar(
                                      "Copied",
                                      "Message copied",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                            
                                  onEdit: () {
                                    showEditDialog(message);
                                  },
                            
                                  onDelete: () {
                            
                                    MessageOverlay.hide();
                            
                                    Future.delayed(
                                      const Duration(milliseconds: 120),
                                          () {
                                        showDeleteConfirmation(
                                          message,
                                          isComing,
                                        );
                                      },
                                    );
                            
                                  },
                            
                                  onShow: () {
                                    selectedMessageId.value = message.id;
                                  },
                            
                                  onDismiss: () {
                                    selectedMessageId.value = "";
                                  },
                                );
                              },
                              child: SwipeTo(
                                onRightSwipe: isComing
                                    ? (details) {
                                        chatController.startReply(message);
                                        messageFocus.requestFocus();
                                      }
                                    : null,
                            
                                onLeftSwipe: !isComing
                                    ? (details) {
                                        chatController.startReply(message);
                                        messageFocus.requestFocus();
                                      }
                                    : null,
                                animationDuration: const Duration(
                                  milliseconds: 180,
                                ),
                            
                                offsetDx: 0.22,
                            
                                child: ChatType(
                                  message: message.message,
                                  imageUrl: message.mediaUrl,
                                  isDeleted: message.isDeleted,
                                  repliedMessage: repliedMessage,
                                  repliedSenderName: repliedSenderName,
                                  isComing: isComing,
                                  time: DateTimeFormatter.formatTime(
                                    message.timeStamp,
                                  ),
                                  status: message.status,
                                  isEdited: message.isEdited,
                                  reactions: message.reactions,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(top: false, child: buildMessageComposer()),
    );
  }
}
