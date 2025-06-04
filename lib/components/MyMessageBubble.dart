import 'package:flutter/material.dart';
import '../logic/MessageService.dart';

class MessageBubble extends StatelessWidget {
  final Message msg;
  final bool isMe;
  final VoidCallback onLongPress;

  const MessageBubble({
    super.key,
    required this.msg,
    required this.isMe,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            msg.text,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}