import 'package:flutter/material.dart';
import 'package:p3/stubs/StubLogicChats.dart';

import '../logic/ChatsService.dart';


class MyAddChatPopup extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  MyAddChatPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Создание нового чата'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Название чата'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            final chatName = _nameController.text;
            //TODO убрать dummy
            ChatsService ch = DummyChatsService();
            ch.createChat(name: chatName);
            print("пытаюсь создать чат с именем $chatName");
            Navigator.of(context).pop(chatName);
            //TODO как-то уведомить что надо еще раз посмотреть какие чаты доступны
          },
          child: const Text('Создать'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}