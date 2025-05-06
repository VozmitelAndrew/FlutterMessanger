import 'package:flutter/material.dart';

import '../logic/ChatsService.dart';


class MyAddChatPopup extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  MyAddChatPopup({Key? key}) : super(key: key);

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
            ChatService ch = ChatService();
            ch.createChat(name: chatName);
            print("пытаюсь создать чат с именем $chatName");
            Navigator.of(context).pop(chatName);
            //TODO как-то уведомить что надо еще раз посмотреть какие чаты доступны
          },
          child: const Text('Создать'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Закрыть попап
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}