import '../logic/MessageService.dart';

class DummyMessageService implements MessageService {
  DummyMessageService._internal();
  static final DummyMessageService _instance = DummyMessageService._internal();
  factory DummyMessageService() => _instance;

  final Map<String, List<Message>> _store = {};

  @override
  Future<bool> sendMessage({required String chatId, required String text}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final msg = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      text: text,
      timestamp: DateTime.now(),
    );
    _store.putIfAbsent(chatId, () => []).add(msg);
    return true;
  }

  @override
  Future<List<Message>> getPreviousMessages({required String chatId}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final messages = List<Message>.from(_store[chatId] ?? []);
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  @override
  Future<List<Message>> getBeforeMessages({required String chatId, required String messageId}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final all = List<Message>.from(_store[chatId] ?? []);
    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final index = all.indexWhere((m) => m.id == messageId);
    return (index != -1) ? all.sublist(0, index) : [];
  }

  @override
  Future<bool> editMessage({required String chatId, required String messageId, required String newText}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final list = _store[chatId] ?? [];
    final idx = list.indexWhere((m) => m.id == messageId);
    if (idx == -1) return false;
    final old = list[idx];
    list[idx] = Message(
      id: old.id,
      chatId: old.chatId,
      memberId: old.memberId,
      text: newText,
      timestamp: old.timestamp,
      isEdited: true,
      isRead: old.isRead,
      viewedBy: old.viewedBy,
    );
    return true;
  }

  @override
  Future<bool> deleteMessage({required String chatId, required String messageId}) async {
    await Future.delayed(Duration(milliseconds: 300));
    final list = _store[chatId] ?? [];
    final initialLength = list.length;
    list.removeWhere((m) => m.id == messageId);
    return list.length < initialLength;
  }

  @override
  Future<bool> markAction({required String chatId, required String messageId, required MessageAction action}) async {
    await Future.delayed(Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<void> retryFailedMessage(String messageId) async {
    await Future.delayed(Duration(milliseconds: 300));
  }

  @override
  void clearLocalCache(String conversationId) {
    _store.remove(conversationId);
  }

  @override
  Future<void> dispose() async {
    await Future.delayed(Duration(milliseconds: 300));
    _store.clear();
  }

  @override
  void notice(String? data) {
    print('I got noticed: \$data');
  }
}
