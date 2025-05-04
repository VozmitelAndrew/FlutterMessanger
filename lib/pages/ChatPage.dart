import 'package:flutter/material.dart';
import '../logic/MessageService.dart';
import '../logic/AuthenticationService.dart';
import '../logic/WebSocketService.dart';

class ChatScreenPage extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  const ChatScreenPage({
    required this.chatId,
    required this.currentUserId,
  });

  @override
  _ChatScreenPageState createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  final TextEditingController _textController = TextEditingController();
  List<Message> messages = [];
  bool _isLoading = true;

  final ChatMessageService mss = ChatMessageService(
    baseUrl: 'http://localhost:8080',
    authService: HttpAuthService(),
    wsService: WebSocketService(),
  );

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
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await mss.sendMessage(chatId: widget.chatId, text: text);
    _textController.clear();

    // Обновляем список сообщений после отправки
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(child: Text('No messages yet'))
                : ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.memberId == widget.currentUserId;
                return _buildMessageBubble(msg, isMe);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
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
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: ChatScreenPage(
        chatId: chatId,
        currentUserId: currentUserId,
      ),
    ),
  );
}