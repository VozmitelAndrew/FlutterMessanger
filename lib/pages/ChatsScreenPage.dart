import 'package:flutter/material.dart';
import 'package:p3/components/MyAddChatPopup.dart';
import 'package:p3/components/MyDrawer.dart';
import 'package:p3/logic/AuthenticationService.dart';
import 'package:p3/logic/WebSocketService.dart';
import 'package:p3/logic/ChatsService.dart';
import 'package:p3/stubs/StubLogicAuth.dart';
import 'package:p3/stubs/StubLogicChats.dart';
import 'LoginRegisterPage.dart';
import 'ChatPage.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({
    super.key,
  });

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  late final AuthenticationService _authService;
  late final WebSocketServiceImpl _wsService;
  late final ChatsService _chatService;

  bool _isLoading = true;
  List<Chat> _chats = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _authService = DummyAuthenticationService();
    _wsService = WebSocketServiceImpl();
    _chatService = DummyChatsService();
    _loadChats();
  }

  Future<void> _loadChats() async {
    print("пытаюсь перезагрузить чаты");
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
    _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
      ),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text('Ошибка: $_error'))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    'Участников: ${chat.membersQuantity}'),
                onTap: () {
                  print('Current user ID: ${_authService.id!}, Chat ID: ${chat.chatId}');
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
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FloatingActionButton(
                  onPressed: _loadChats,
                  child: const Icon(Icons.refresh),
                ),
                FloatingActionButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => MyAddChatPopup(),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}