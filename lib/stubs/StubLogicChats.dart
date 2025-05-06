import '../logic/ChatsService.dart';

class DummyChatsService implements ChatsService {
  DummyChatsService._internal();
  static final DummyChatsService _instance = DummyChatsService._internal();
  factory DummyChatsService() => _instance;


  final Map<String, Chat> _chats = {};
  final Map<String, List<Member>> _members = {};
  int _chatCounter = 0;
  int _memberCounter = 1;

  @override
  Future<Chat> createChat({required String name}) async {
    await Future.delayed(Duration(milliseconds: 300));
    _chatCounter++;
    final chatId = 'chat_$_chatCounter';
    print('Создаю чат с именем $name');
    final chat = Chat(chatId: chatId, name: name, membersQuantity: 1);
    _chats[chatId] = chat;
    print(_chats.values);
    _members[chatId] = [];
    return chat;
  }

  @override
  Future<List<Chat>> getChats() async {
    await Future.delayed(Duration(milliseconds: 300));
    print(_chats.values);
    return _chats.values.toList();
  }

  @override
  Future<bool> updateChat({required String chatId, required String newName}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final chat = _chats[chatId];
    if (chat == null) return false;
    chat.name = newName;
    return true;
  }

  @override
  Future<bool> deleteChat({required String chatId}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final removed = _chats.remove(chatId) != null;
    _members.remove(chatId);
    return removed;
  }

  @override
  Future<Member?> addMember({
    required String chatId,
    required String tag,
    required Role role,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    print("я пытаюст добавить нового мембера");
    final chat = _chats[chatId];
    if (chat == null) return null;
    _memberCounter++;
    print(_memberCounter);
    // Исправляем опечатку (убираем пробел)
    final memberId = 'member_$_memberCounter';
    final member = Member(
      memberId: memberId,
      username: tag,
      role: role,
      activity: Activity.inactive,
    );
    _members[chatId]!.add(member);
    chat.membersQuantity = _members[chatId]!.length;
    return member;
  }

  @override
  Future<bool> deleteMember({required String chatId, required String memberId}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final members = _members[chatId];
    if (members == null) return false;
    final initialCount = members.length;
    members.removeWhere((m) => m.memberId == memberId);
    _chats[chatId]?.membersQuantity = members.length;
    return members.length < initialCount;
  }
}