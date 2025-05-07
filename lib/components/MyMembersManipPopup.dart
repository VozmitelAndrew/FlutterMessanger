import 'package:flutter/material.dart';
import 'package:p3/stubs/StubLogicChats.dart';
import '../logic/ChatsService.dart';

class MyMembersManipPopup extends StatefulWidget {
  final String chatId;
  final String userId;

  MyMembersManipPopup({Key? key, required this.chatId, required this.userId}) : super(key: key);

  @override
  _MyMembersManipPopupState createState() => _MyMembersManipPopupState();
}

class _MyMembersManipPopupState extends State<MyMembersManipPopup> {
  final DummyChatsService _ch = DummyChatsService();
  final TextEditingController _nameController = TextEditingController();
  List<Member> _members = [];
  Member? _selectedMember;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final list = _ch.membersMap[widget.chatId]!;
    setState(() {
      _members = list;
      _selectedMember = list.isNotEmpty ? list.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Управление участниками'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Имя участника',
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _nameController.text.isEmpty
                ? null
                : () async {
              final member = await _ch.addMember(
                chatId: widget.chatId,
                tag: _nameController.text,
                role: Role.member,
              );
              Navigator.of(context).pop(member);
            },
            child: const Text('+ участник'),
          ),
          const Divider(),
          DropdownButton<Member>(
            isExpanded: true,
            value: _selectedMember,
            hint: const Text('Выберите участника'),
            items: _members.map((m) {
              return DropdownMenuItem<Member>(
                value: m,
                child: Text(m.username),
              );
            }).toList(),
            onChanged: (m) => setState(() => _selectedMember = m),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _selectedMember == null
                ? null
                : () async {
              final success = await _ch.deleteMember(
                chatId: widget.chatId,
                memberId: _selectedMember!.memberId,
              );
              Navigator.of(context).pop(success);
            },
            child: const Text('- участник'),
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
