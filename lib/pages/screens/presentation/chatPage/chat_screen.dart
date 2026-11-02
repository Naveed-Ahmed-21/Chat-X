import 'dart:async';
import 'dart:developer' as developer;

import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/chat_type.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/date_separator.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/empty_chat_widget.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/message_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../controller/chat_controller.dart';
import '../../../../controller/user_contact_controller.dart';
import '../../../../model/chat_room_model.dart';
import '../../../../model/message_model.dart';
import '../../../../services/audio_record_service.dart';
import '../../../../services/upload_service.dart';
import '../../../../services/video_thumbnail_service.dart';
import '../../../../utils/date_time_formatter.dart';
import '../../../../widgets/message_status.dart';
import '../../../../widgets/message_type.dart';
import '../../mediaPreview/media_preview_screen.dart';
import 'package:chatx_app/pages/group/group_info_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:chatx_app/pages/screens/presentation/chatPage/message_info_screen.dart';
import 'package:chatx_app/widgets/media/image_viewer_screen.dart';

import 'forward_message_screen.dart';

class ChatScreen extends StatefulWidget {
  final UserModel? user;
  final ChatRoomModel? chatRoom;
  const ChatScreen({super.key, this.user, this.chatRoom});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRoomController chatRoomController = Get.find<ChatRoomController>();
  final ChatController chatController = Get.find();
  final UserContactController userController = Get.find();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ImagePicker picker = ImagePicker();
  final UploadService uploadService = UploadService();
  final VideoThumbnailService thumbnailService = VideoThumbnailService();
  TextEditingController messageController = TextEditingController();
  final AudioRecordService audioService = AudioRecordService();
  final FocusNode messageFocus = FocusNode();

  late final String roomId;
  late final String receiverId;
  late final Stream<List<MessageModel>> messageStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> roomStream;
  final RxString selectedMessageId = "".obs;

  String? audioPath;

  int previousMessageCount = 0;

  final RxBool hasText = false.obs;
  final RxList<UserModel> mentionsList = <UserModel>[].obs;
  RxBool isRecording = false.obs;
  final RxBool isRecordingCancelled = false.obs;

  bool hasInitialScroll = false;
  bool isAtBottom = true;

  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();

    if (widget.chatRoom != null) {
      roomId = widget.chatRoom!.id;
      if (widget.chatRoom!.isGroup) {
        receiverId = widget.chatRoom!.id;
      } else {
        receiverId = widget.chatRoom!.participants.firstWhere(
          (uid) => uid != FirebaseAuth.instance.currentUser?.uid,
          orElse: () => widget.chatRoom!.id,
        );
      }
    } else {
      receiverId = widget.user!.uid;
      roomId = chatRoomController.getRoomId(receiverId);
      chatRoomController.createOrUpdateRoom(
        receiverId: receiverId,
        lastMessage: "",
      );
    }

    messageStream = chatController.getMessages(roomId);
    roomStream = FirebaseFirestore.instance
        .collection("chats")
        .doc(roomId)
        .snapshots()
        .handleError((e) {
          developer.log(
            'Chat room stream failed.',
            name: 'ChatScreen',
            error: e,
          );
        });

    messageController.addListener(() {
      final text = messageController.text;
      hasText.value = text.trim().isNotEmpty;

      // Debounced typing status
      if (_typingTimer?.isActive ?? false) _typingTimer?.cancel();

      if (text.trim().isNotEmpty) {
        _typingTimer = Timer(const Duration(milliseconds: 500), () {
          chatController.setTypingStatus(roomId, "typing...");
        });
      } else {
        chatController.clearTypingStatus(roomId);
      }

      // Mentions logic
      if (widget.chatRoom != null && text.contains("@")) {
        final lastAt = text.lastIndexOf("@");
        final query = text.substring(lastAt + 1).toLowerCase();

        if (!query.contains(" ")) {
          mentionsList.assignAll(
            userController.userList
                .where((u) => widget.chatRoom!.participants.contains(u.uid))
                .where((u) => u.name.toLowerCase().contains(query))
                .toList(),
          );
        } else {
          mentionsList.clear();
        }
      } else {
        mentionsList.clear();
      }
    });

    chatController.markMessagesAsDelivered();
  }

  @override
  void dispose() {
    messageController.dispose();
    MessageOverlay.hide();
    audioService.dispose();
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

  void _showDeleteChatConfirm() {
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
        chatRoomController.deleteChatForMe(roomId);
        Get.offAllNamed("/homeScreen");
      },
    );
  }

  void showDeleteConfirmation(MessageModel message, bool isComing) {
    final bool isAdmin =
        widget.chatRoom?.admins.contains(
          FirebaseAuth.instance.currentUser?.uid,
        ) ??
        false;

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

          if (!isComing || (widget.chatRoom?.isGroup == true && isAdmin))
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
          /// Mentions list
          Obx(() {
            if (mentionsList.isEmpty) return const SizedBox();
            return Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mentionsList.length,
                itemBuilder: (context, index) {
                  final user = mentionsList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 15,
                      backgroundImage: user.profilePic.isNotEmpty
                          ? NetworkImage(user.profilePic)
                          : null,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      final text = messageController.text;
                      final lastAt = text.lastIndexOf("@");
                      final newText =
                          "${text.substring(0, lastAt)}@${user.name} ";
                      messageController.text = newText;
                      messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: newText.length),
                      );
                      mentionsList.clear();
                    },
                  );
                },
              ),
            );
          }),

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

              Obx(() {
                if (isRecording.value) {
                  return Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          "Recording...",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        const Flexible(
                          child: Text(
                            "< Slide to cancel",
                            style: TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.grey,
                          size: 14,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  );
                }
                return Expanded(
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
                );
              }),

              Obx(
                () => isRecording.value
                    ? const SizedBox()
                    : IconButton(
                        onPressed: showMediaPicker,
                        icon: const Icon(Icons.photo_library_rounded),
                      ),
              ),

              Obx(() {
                return hasText.value
                    ? IconButton(
                        onPressed: () async {
                          final text = messageController.text.trim();

                          if (text.isEmpty) return;

                          messageController.clear();

                          unawaited(
                            chatController.sendTextMessage(
                              receiverId: receiverId,
                              text: text,
                              roomId: roomId,
                              isGroup: widget.chatRoom?.isGroup ?? false,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.send_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Obx(
                        () => GestureDetector(
                          onLongPressStart: (_) async {
                            isRecordingCancelled.value = false;
                            await startRecording();
                          },
                          onLongPressMoveUpdate: (details) {
                            if (details.localOffsetFromOrigin.dx < -100) {
                              if (!isRecordingCancelled.value) {
                                isRecordingCancelled.value = true;
                                HapticFeedback.heavyImpact();
                              }
                            } else if (details.localOffsetFromOrigin.dx > -20) {
                              if (isRecordingCancelled.value) {
                                isRecordingCancelled.value = false;
                              }
                            }
                          },
                          onLongPressEnd: (details) async {
                            if (isRecordingCancelled.value) {
                              await audioService.stopRecording();
                              isRecordingCancelled.value = false;
                              isRecording.value = false;
                            } else {
                              await stopRecording();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRecording.value
                                  ? (isRecordingCancelled.value
                                        ? Colors.grey
                                        : Colors.red)
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            child: Icon(
                              isRecording.value
                                  ? (isRecordingCancelled.value
                                        ? Icons.delete_outline
                                        : Icons.mic)
                                  : Icons.mic_none,
                              color: Colors.white,
                              size: isRecording.value ? 28 : 24,
                            ),
                          ),
                        ),
                      );
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
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Get.back();
                  pickMultipleImages();
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {
                  Get.back();
                  pickCameraImage();
                },
              ),

              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text("Video"),
                onTap: () {
                  Get.back();
                  pickVideoFromGallery();
                },
              ),

              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Record Video"),
                onTap: () {
                  Get.back();
                  recordVideo();
                },
              ),

              ListTile(
                leading: const Icon(Icons.insert_drive_file_rounded),
                title: const Text("Document"),
                onTap: () {
                  Get.back();
                  pickDocument();
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

  Future<void> pickVideoFromGallery() async {
    final video = await picker.pickVideo(source: ImageSource.gallery);

    if (video == null) return;
    await _sendVideoOptimistically(video);
  }

  Future<void> recordVideo() async {
    final file = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );

    if (file == null) return;
    await _sendVideoOptimistically(file);
  }

  Future<void> _sendVideoOptimistically(XFile file) async {
    try {
      final messageId = await chatController.sendVideoMessage(
        receiverId: receiverId,
        videoUrl: '',
        duration: 0,
        thumbnail: '',
        localPath: file.path,
        status: MessageStatus.sending,
        roomId: roomId,
        isGroup: widget.chatRoom != null,
      );

      unawaited(() async {
        try {
          final thumbnailPath = await thumbnailService.generateThumbnail(
            file.path,
          );
          if (thumbnailPath != null) {
            await chatController.updateMessage(receiverId, messageId, {
              'thumbnail': thumbnailPath,
            }, roomId: roomId);
          }

          final results = await Future.wait<dynamic>([
            uploadService.uploadVideo(file.path),
            if (thumbnailPath != null)
              uploadService.uploadChatImage(thumbnailPath),
          ]);
          final videoResult = results.first as Map<String, dynamic>;
          final thumbnailUrl = thumbnailPath == null
              ? ''
              : results[1] as String;
          await chatController.updateMessage(receiverId, messageId, {
            'mediaUrl': videoResult['videoUrl'],
            'duration': videoResult['duration'] ?? 0,
            'thumbnail': thumbnailUrl,
            'status': MessageStatus.sent.name,
          }, roomId: roomId);
        } catch (error, stackTrace) {
          developer.log(
            'Video upload failed.',
            name: 'ChatScreen',
            error: error,
            stackTrace: stackTrace,
          );
          await chatController.updateMessage(receiverId, messageId, {
            'status': MessageStatus.failed.name,
          }, roomId: roomId);
        }
      }());
    } catch (error, stackTrace) {
      developer.log(
        'Could not queue the outgoing video.',
        name: 'ChatScreen',
        error: error,
        stackTrace: stackTrace,
      );
      Get.snackbar('Video not sent', 'Could not add this video to the chat.');
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      final files = await picker.pickMultiImage(imageQuality: 80);

      if (files.isEmpty) return;

      Get.to(
        () => MediaPreviewScreen(
          files: files,
          receiverId: receiverId,
          roomId: roomId,
          isGroup: widget.chatRoom != null,
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> pickCameraImage() async {
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (file == null) return;

    // Send optimistic image message immediately so camera photo shows in chat
    final String messageId = await chatController.sendImageMessage(
      receiverId: receiverId,
      imageUrl: "",
      localPath: file.path,
      status: MessageStatus.sending,
      roomId: roomId,
      isGroup: widget.chatRoom != null,
    );

    unawaited(() async {
      try {
        final imageUrl = await uploadService.uploadChatImage(file.path);
        await chatController.updateMessage(receiverId, messageId, {
          "mediaUrl": imageUrl,
          "status": MessageStatus.sent.name,
        }, roomId: roomId);
      } catch (e) {
        developer.log(
          'Camera image upload failed.',
          name: 'ChatScreen',
          error: e,
        );
        await chatController.updateMessage(receiverId, messageId, {
          "status": MessageStatus.failed.name,
        }, roomId: roomId);
      }
    }());
  }

  Future<void> startRecording() async {
    try {
      audioPath = await audioService.startRecording();

      isRecording.value = true;
      chatController.setTypingStatus(roomId, "recording audio...");
    } catch (e) {
      Get.snackbar("Permission", e.toString());
    }
  }

  Future<void> stopRecording() async {
    final path = await audioService.stopRecording();

    isRecording.value = false;
    chatController.clearTypingStatus(roomId);

    if (path == null) return;

    try {
      final player = AudioPlayer();
      await player.setFilePath(path);
      final duration = player.duration?.inMilliseconds ?? 0;
      await player.dispose();

      // Optimistic sending
      final String messageId = await chatController.sendAudioMessage(
        receiverId: receiverId,
        audioUrl: "",
        localPath: path,
        duration: duration,
        status: MessageStatus.sending,
        roomId: roomId,
        isGroup: widget.chatRoom != null,
      );

      // Background upload
      unawaited(() async {
        try {
          final audioUrl = await uploadService.uploadAudio(path);

          await chatController.updateMessage(receiverId, messageId, {
            "mediaUrl": audioUrl,
            "status": MessageStatus.sent.name,
          }, roomId: roomId);
        } catch (e) {
          developer.log('Audio upload failed.', name: 'ChatScreen', error: e);
          await chatController.updateMessage(receiverId, messageId, {
            "status": MessageStatus.failed.name,
          }, roomId: roomId);
        }
      }());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    final file = result.files.single;

    if (file.path == null) return;

    try {
      // Optimistic sending
      final String messageId = await chatController.sendFileMessage(
        receiverId: receiverId,
        fileUrl: "",
        fileName: file.name,
        fileSize: file.size,
        extension: file.extension ?? "",
        localPath: file.path!,
        status: MessageStatus.sending,
        roomId: roomId,
        isGroup: widget.chatRoom != null,
      );

      // Background upload
      unawaited(() async {
        try {
          final response = await uploadService.uploadFile(file.path!);

          await chatController.updateMessage(receiverId, messageId, {
            "mediaUrl": response["fileUrl"],
            "status": MessageStatus.sent.name,
            "fileName": response["fileName"],
            "fileSize": response["size"],
            "extension": response["extension"],
          }, roomId: roomId);
        } catch (e) {
          developer.log('File upload failed.', name: 'ChatScreen', error: e);
          await chatController.updateMessage(receiverId, messageId, {
            "status": MessageStatus.failed.name,
          }, roomId: roomId);
        }
      }());
    } catch (e) {
      Get.snackbar("Error", "Failed to send document: $e");
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
            if (widget.chatRoom?.isGroup == true) {
              Get.to(() => GroupInfoScreen(chatRoom: widget.chatRoom!));
            } else {
              Get.toNamed('/userProfileScreen', arguments: widget.user);
            }
          },
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  final img = (widget.chatRoom?.isGroup == true)
                      ? widget.chatRoom!.groupImage
                      : widget.user!.profilePic;
                  if (img.startsWith("http")) {
                    Get.to(
                      () => ImageViewerScreen(
                        imageUrl: img,
                        heroTag: "chat_profile_$roomId",
                      ),
                    );
                  }
                },
                child: Hero(
                  tag: "chat_profile_$roomId",
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: (widget.chatRoom?.isGroup == true)
                        ? (widget.chatRoom!.groupImage.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  widget.chatRoom!.groupImage,
                                )
                              : null)
                        : (widget.user!.profilePic.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  widget.user!.profilePic,
                                )
                              : null),
                    child: (widget.chatRoom?.isGroup == true)
                        ? (widget.chatRoom!.groupImage.isEmpty
                              ? Image.asset(AppImages.appLogo)
                              : null)
                        : (widget.user!.profilePic.isEmpty
                              ? Image.asset(AppImages.male)
                              : null),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatRoom?.isGroup == true
                        ? widget.chatRoom!.groupName
                        : widget.user!.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: roomStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data?.data() == null ||
                          !snapshot.data!.exists) {
                        return Text(
                          widget.chatRoom?.isGroup == true
                              ? "${widget.chatRoom!.participants.length} members"
                              : widget.user!.status,
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      }

                      final data = snapshot.data!.data()!;
                      final typingMap = Map<String, String>.from(
                        data['typingStatus'] ?? {},
                      );
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;

                      // Filter out current user from typing status
                      typingMap.remove(currentUid);

                      if (typingMap.isNotEmpty) {
                        final typingUid = typingMap.keys.first;
                        final status = typingMap[typingUid];

                        return FutureBuilder<UserModel?>(
                          future: userController.getUserById(typingUid),
                          builder: (context, userSnap) {
                            final name = userSnap.data?.name ?? "Someone";
                            return Text(
                              "$name is $status",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            );
                          },
                        );
                      }

                      if (widget.chatRoom?.isGroup == true) {
                        final participants = data['participants'] as List;
                        return StreamBuilder<List<UserModel>>(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .snapshots()
                              .map(
                                (s) => s.docs
                                    .map((d) => UserModel.fromJson(d.data()))
                                    .where((u) => participants.contains(u.uid))
                                    .where(
                                      (u) => u.lastOnlineStatus == "online",
                                    )
                                    .toList(),
                              ),
                          builder: (context, onlineSnap) {
                            final onlineCount = onlineSnap.data?.length ?? 0;
                            return Text(
                              "${participants.length} members${onlineCount > 0 ? ' ($onlineCount online)' : ''}",
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        );
                      }

                      return Text(
                        widget.chatRoom?.isGroup == true
                            ? "${(data['participants'] as List).length} members"
                            : widget.user!.status,
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "delete") {
                _showDeleteChatConfirm();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "delete",
                child: Text(
                  "Delete Chat",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
            icon: Icon(Icons.more_vert, color: Colors.grey[200]),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder<List<MessageModel>>(
                stream: messageStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const EmptyChatWidget();
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const EmptyChatWidget();
                  }

                  final currentUser = FirebaseAuth.instance.currentUser!.uid;

                  final firstUnreadIndex = messages.indexWhere(
                    (m) =>
                        m.receiverId == currentUser &&
                        m.status != MessageStatus.seen,
                  );

                  // Live real-time read receipt trigger for incoming messages
                  final hasUnseenIncoming = messages.any(
                    (m) =>
                        m.receiverId == currentUser &&
                        m.status != MessageStatus.seen,
                  );

                  if (hasUnseenIncoming) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      chatController.markMessagesAsSeen(
                        roomId,
                        receiverId,
                        isGroup: widget.chatRoom?.isGroup == true,
                      );
                    });
                  }

                  if (!hasInitialScroll && messages.isNotEmpty) {
                    hasInitialScroll = true;

                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      chatController.updateLastReadTimestamp(roomId);
                    });
                  }

                  return ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final imageMessages = messages
                          .where((m) => m.type == MessageType.image)
                          .toList();

                      final currentImageIndex = imageMessages.indexWhere(
                        (m) => m.id == message.id,
                      );

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
                          : widget.chatRoom?.isGroup == true
                          ? (userController.userList
                                    .firstWhereOrNull(
                                      (u) => u.uid == repliedMessage!.senderId,
                                    )
                                    ?.name ??
                                "Unknown")
                          : widget.user!.name;

                      // Date separator check for reverse: true list (index messages.length - 1 is oldest message)
                      bool showDate = false;
                      if (index == messages.length - 1) {
                        showDate = true;
                      } else {
                        final olderMessage = messages[index + 1];

                        showDate =
                            DateTimeFormatter.chatDate(
                              olderMessage.timeStamp,
                            ) !=
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

                          Builder(
                            builder: (messageContext) {
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

                                    onForward: () {
                                      Get.to(
                                        () => ForwardMessageScreen(
                                          message: message,
                                        ),
                                      );
                                    },

                                    onInfo:
                                        !isComing &&
                                            widget.chatRoom?.isGroup == true
                                        ? () {
                                            Get.to(
                                              () => MessageInfoScreen(
                                                message: message,
                                              ),
                                            );
                                          }
                                        : null,

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
                                    messageModel: message,
                                    type: message.type,
                                    imageUrl: message.mediaUrl,
                                    thumbnail: message.thumbnail,
                                    imageMessages: imageMessages,
                                    currentImageIndex: currentImageIndex,
                                    heroTag: message.id,
                                    message: message.message,
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
                                    senderName: widget.chatRoom?.isGroup == true
                                        ? (isComing
                                              ? (userController.userList
                                                        .firstWhereOrNull(
                                                          (u) =>
                                                              u.uid ==
                                                              message.senderId,
                                                        )
                                                        ?.name ??
                                                    "Unknown")
                                              : "you")
                                        : "",
                                    onSenderTap:
                                        widget.chatRoom?.isGroup == true
                                        ? () {
                                            final uid = isComing
                                                ? message.senderId
                                                : FirebaseAuth
                                                      .instance
                                                      .currentUser
                                                      ?.uid;
                                            final user = userController.userList
                                                .firstWhereOrNull(
                                                  (u) => u.uid == uid,
                                                );
                                            if (user != null) {
                                              Get.toNamed(
                                                '/userProfileScreen',
                                                arguments: user,
                                              );
                                            }
                                          }
                                        : null,
                                    groupMembers: userController.userList,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SafeArea(top: false, child: buildMessageComposer()),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
