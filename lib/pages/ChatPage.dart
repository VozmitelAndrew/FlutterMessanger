import 'package:flutter/material.dart';
import 'package:p3/components/MyMembersManipPopup.dart';
import 'package:p3/stubs/StubLogicAuth.dart';
import 'package:p3/stubs/StubLogicMessage.dart';
import '../components/MyAddChatPopup.dart';
import '../logic/MessageService.dart';
import '../logic/AuthenticationService.dart';
import '../logic/WebSocketService.dart';

class ChatScreenPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatScreenPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });

  @override
  _ChatScreenPageState createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  final _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();
  List<Message> messages = [];
  bool _isLoading = true;

  final MessageService mss = DummyMessageService();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await mss.getPreviousMessages(chatId: widget.chatId);
    setState(() {
      messages = loadedMessages;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    _focusNode.requestFocus();
    if (text.isEmpty) return;

    await mss.sendMessage(chatId: widget.chatId, text: text);
    _textController.clear();

    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat ${widget.chatId}'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed:
                    () => showDialog(
                      context: context,
                      builder: (context) => MyMembersManipPopup(chatId: widget.chatId, userId: widget.currentUserId),
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : messages.isEmpty
                    ? Center(child: Text('No messages yet'))
                    : Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          //print(msg.memberId);
                          //print( widget.currentUserId);
                          final isMe = msg.memberId == widget.currentUserId;
                          return _buildMessageBubble(msg, isMe);
                        },
                      ),
                    ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    //print('Я ли: $isMe');
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
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
            color: isMe ? Colors.white : Colors.black26,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showChatPopup(
  BuildContext context, {
  required String chatId,
  required String currentUserId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (_) => FractionallySizedBox(
          heightFactor: 0.9,
          child: ChatScreenPage(chatId: chatId, currentUserId: currentUserId),
        ),
  );
}
