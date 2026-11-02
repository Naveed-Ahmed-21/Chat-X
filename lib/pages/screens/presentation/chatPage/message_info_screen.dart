import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/model/user_model.dart';
import 'package:chatx_app/controller/user_contact_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageInfoScreen extends StatelessWidget {
  final MessageModel message;
  const MessageInfoScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final UserContactController userController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Message Info"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Message", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(message.message.isEmpty ? "[Media]" : message.message),
                    const SizedBox(height: 10),
                    Text(
                      "Sent at ${DateFormat('HH:mm').format(message.timeStamp ?? DateTime.now())}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.centerLeft, child: Text("Seen by", style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: message.seenBy.length,
              itemBuilder: (context, index) {
                final uid = message.seenBy[index];
                return FutureBuilder<UserModel?>(
                  future: userController.getUserById(uid),
                  builder: (context, snap) {
                    final user = snap.data;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user?.profilePic.isNotEmpty == true ? NetworkImage(user!.profilePic) : null,
                        child: user?.profilePic.isEmpty == true ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user?.name ?? "Loading..."),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
