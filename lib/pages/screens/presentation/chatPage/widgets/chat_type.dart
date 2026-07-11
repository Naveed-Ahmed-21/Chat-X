import 'package:chatx_app/widgets/message_status.dart';
import 'package:flutter/material.dart';

class ChatType extends StatelessWidget {

  final String message;
  final String imageUrl;
  final bool isComing;
  final String time;
  final String status;

  const ChatType({
    super.key,
    required this.message,
    required this.imageUrl,
    required this.isComing,
    required this.time,
    required this.status
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width/1.3
            ),
            decoration: BoxDecoration(
              borderRadius: isComing
                  ?  BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(10),
                    )
                  :  BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(0),
                    ),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: imageUrl == ''
                ? Text(message)
                :Column(
              crossAxisAlignment: isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius : BorderRadius.circular(10),
                  child: Image.network(
                      imageUrl,
                    width: 250,
                    fit: BoxFit.cover,
                    loadingBuilder: (context , child , loadingProgress){
                        if(loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                    },
                    errorBuilder: (context , error, stackTrace){
                        return Icon(
                          Icons.broken_image_outlined,
                          size: 100,
                        );
                    },
                  ),
                ),
                SizedBox(height: 10,),
                Text(message)
              ],
            ),
          ),
          SizedBox(height: 10,),

          Row(
            mainAxisAlignment: isComing ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              isComing
                  ? Text(
                  time,
                style: Theme.of(context).textTheme.labelMedium,
              )
                  : Row(
                children: [
                  Text(
                      time,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  SizedBox(width: 5,),
                  // MessageStatus.values == "read"
                  //     ? Icon(
                  //         Icons.done_all,
                  //         color: Colors.blueAccent
                  //     ) : MessageStatus.values == "delivered" ? Icon(
                  //     Icons.done_all,
                  //   color: Colors.grey,
                  // ) : MessageStatus.values == "sent" ? Icon(
                  //     Icons.done,
                  //   color: Colors.grey,
                  // ) : Icon(
                  //     Icons.update,
                  //   color: Colors.grey,
                  // )
                  // Icon(
                  //     Icons.done_all,
                  //   color: Colors.grey,
                  // )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
