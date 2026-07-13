import 'package:chatx_app/config/imgepaths.dart';
import 'package:chatx_app/controller/chat_room_controller.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/chat_type.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/empty_chat_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import '../../../../controller/chat_controller.dart';
import '../../../../model/message_model.dart';
import '../../../../utils/date_time_formatter.dart';


class ChatScreen extends StatefulWidget {
  final UserModel user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final ChatRoomController chatRoomController = Get.find<ChatRoomController>();
  final ChatController chatController = Get.find();
  final ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  late final roomId = chatRoomController.getRoomId(widget.user.uid);

  @override
  void initState() {
    super.initState();

    chatController.markMessagesAsSeen(
      roomId,
      widget.user.uid,
    );
    chatController.markMessagesAsDelivered();

    // print("========================");
    // print("Current User : ${FirebaseAuth.instance.currentUser!.uid}");
    // print("Target User  : ${widget.user.uid}");
    // print("Room ID      : $roomId");
    // print("========================");

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
          onTap: (){
            Get.toNamed(
                '/userProfileScreen',
              arguments: widget.user,

            );
          },
          child: Row(
            children: [
              CircleAvatar(
                  radius: 22,
                  backgroundImage: widget.user.profilePic.isNotEmpty
                      ? NetworkImage(widget.user.profilePic)
                      : null,
                  child: widget.user.profilePic.isEmpty ? Image.asset(AppImages.male) : const Icon(Icons.person)  ,
                ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.user.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(widget.user.status, style: Theme.of(context).textTheme.bodySmall),
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
                // width: 30,
                // height: 30,
                child: Icon(Icons.mic, size: 25),
              ),
            ),

            SizedBox(width: 5),

            Expanded(
              child: TextField(
                controller: messageController,
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

            InkWell(
              onTap: ()  async{
                final text = messageController.text.trim();
                if(text.isEmpty) {
                  return;
                }

                messageController.clear();

                await chatController.sendTextMessage(
                    receiverId: widget.user.uid,
                    text: text
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
            ),
          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.only(bottom: 70, top: 10, left:  10 , right:  10),

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

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });

            final messages = snapshot.data!;

            return ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return ChatType(
                  message: message.message,
                  imageUrl: message.mediaUrl,
                  isComing:
                  message.senderId != FirebaseAuth.instance.currentUser!.uid,
                  time: DateTimeFormatter.formatTime(message.timeStamp),
                  status: message.status,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
