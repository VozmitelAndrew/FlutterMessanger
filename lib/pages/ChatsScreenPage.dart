import 'package:flutter/material.dart';
import 'package:p3/components/MyDrawer.dart';
import 'package:p3/logic/AuthenticationService.dart';
import 'package:p3/logic/WebSocketService.dart';
import 'package:p3/logic/ChatService.dart';
import 'LoginRegisterPage.dart';
import 'ChatPage.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final AuthenticationService _authService;
  late final WebSocketService _wsService;
  late final ChatService _chatService;

  bool _isLoading = true;
  List<Chat> _chats = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _authService = HttpAuthService();
    _wsService = WebSocketService();
    _chatService = ChatService(
      baseUrl: 'http://localhost:8080',
      authService: _authService,
      wsService: _wsService,
    );

    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final chats = await _chatService.getChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Ошибка: $_error'))
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                chat.name.isNotEmpty ? chat.name[0] : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              chat.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Участников: ${chat.membersQuantity}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreenPage(
                    chatId: chat.chatId,
                    currentUserId: _authService.id!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
