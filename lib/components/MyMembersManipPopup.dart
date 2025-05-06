import 'dart:math';

import 'package:flutter/material.dart';
import 'package:p3/stubs/StubLogicChats.dart';
import '../logic/ChatsService.dart';

class MyMembersManipPopup extends StatelessWidget {
  final String chatId;
  final String userId;

  MyMembersManipPopup({Key? key, required this.chatId, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ChatsService ch = DummyChatsService();

    return AlertDialog(
      title: const Text('Управление участниками'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              final random = Random().nextInt(1000) + 1;
              final tag = 'user$random';
              final member = await ch.addMember(
                chatId: chatId,
                tag: tag,
                role: Role.member,
              );
              print('Добавлен участник: $tag');
              Navigator.of(context).pop(member);
            },
            child: const Text('+ участники'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ch.deleteMember(
                chatId: chatId,
                memberId: userId,
              );
              print('Удалить участника: \$success');
              Navigator.of(context).pop(success);
            },
            child: const Text('- участники'),
          ),
          Visibility(
            visible: true,
            child: TextButton(
              onPressed: () {
                // TODO: назначить админом
                print('Назначен админом');
                Navigator.of(context).pop();
              },
              child: const Text('Назначить админом'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}
