import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:p3/stubs/StubLogicAuth.dart';

import '../patternTemplates/ViewerPattern.dart';
import 'AuthenticationService.dart';
import 'WebSocketService.dart';



abstract class MessageService implements Viewer {
  Future<bool> sendMessage({
    required String chatId,
    required String text,
  });

  Future<List<Message>> getPreviousMessages({
    required String chatId,
  });

  Future<List<Message>> getBeforeMessages({
    required String chatId,
    required String messageId,
  });

  Future<bool> editMessage({
    required String chatId,
    required String messageId,
    required String newText,
  });

  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  });

  Future<bool> markAction({
    required String chatId,
    required String messageId,
    required MessageAction action,
  });

  Future<void> retryFailedMessage(String messageId);

  void clearLocalCache(String conversationId);

  Future<void> dispose();
}



class HTTPMessageService implements MessageService {
  final String _baseUrl;
  final AuthenticationService _authService;
  final WebSocketServiceImpl _wsService;

  final Map<String, Message> _failedMessages = {};

  HTTPMessageService({
    required String baseUrl,
    required AuthenticationService authService,
    required WebSocketServiceImpl wsService,
  }) : _baseUrl = baseUrl,
       _authService = authService,
       _wsService = wsService {
    _wsService.init();
    _wsService.subscribe(this);
    _wsService.listen();
  }

  @override
  Future<bool> sendMessage({
    required String chatId,
    required String text,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chats/$chatId/messages'),
        headers: _authHeader(),
        body: jsonEncode(<String, String>{'text': text}),
      );
      return true;
    } catch (e) {
      // Сохраняем в кеш для retry
      final msg = Message(
        id: UniqueKey().toString(),
        chatId: chatId,
        text: text,
        timestamp: DateTime.now(),
      );
      _failedMessages[msg.id] = msg;
      print("не отправлено сообщение ${msg.id}");
      return false;
    }
  }

  // /// Загрузка истории сообщений через REST API
  // Future<List<Message>> loadEarlierMessages({
  //   required String chatId,
  //   required String messageId,
  // }) async {
  //   final resp = await http.get(
  //     Uri.parse('$_baseUrl/chats/$chatId/messages/$messageId'),
  //     headers: _authHeader(),
  //   );
  //   if (resp.statusCode == 200) {
  //     final List data = jsonDecode(resp.body) as List;
  //     return data.map((e) => Message.fromJson(e)).toList();
  //   }
  //   throw Exception('Ошибка загрузки истории: \${resp.statusCode}');
  // }
  @override
  Future<List<Message>> getPreviousMessages({
  required String chatId,
  }) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/chats/$chatId/messages'),
      headers: _authHeader(),
    );
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body) as List;
      print(data);
      return data.map((e) => Message.fromJson(e)).toList();
    }
    throw Exception('Ошибка загрузки истории: \${resp.statusCode}');
  }

  @override
  Future<List<Message>> getBeforeMessages({
    required String chatId,
    required String messageId,
  }) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/chats/$chatId/messages/$messageId'),
      headers: _authHeader(),
    );
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body) as List;
      return data.map((e) => Message.fromJson(e)).toList();
    }
    throw Exception('Ошибка загрузки истории: \${resp.statusCode}');
  }

  @override
  Future<bool> editMessage({
    required String chatId,
    required String messageId,
    required String newText,
  }) async {
    final resp = await http.patch(
      Uri.parse('$_baseUrl/chats/$chatId/messages/$messageId'),
      headers: _authHeader(),
      body: jsonEncode({'text': newText}),
    );
    return resp.statusCode == 200;
  }

  @override
  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    final resp = await http.delete(
      Uri.parse('$_baseUrl/chats/$chatId/messages/$messageId'),
      headers: _authHeader(),
    );
    return resp.statusCode == 200;
  }

  /// Пометка как прочитанного
  // Future<bool> markAction(String chatId, List<String> messageIds) async {
  //   final results = await Future.wait(
  //     messageIds.map((messageId) async {
  //       try {
  //         final uri = Uri.parse(
  //           '$_baseUrl/chats/$chatId/messages/$messageId?action=VIEWED',
  //         );
  //         final response = await http.post(uri, headers: _authHeader());
  //         return response.statusCode == 200;
  //       } catch (e) {
  //         return false; // Обработка ошибок сети или сервера
  //       }
  //     }),
  //   );
  //   // Возвращает true только если все запросы успешны
  //   return results.every((isSuccess) => isSuccess);
  // }

  @override
  Future<bool> markAction({
    required String chatId,
    required String messageId,
    required MessageAction action,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chats/$chatId/messages/$messageId?action=${action.name}'),
      headers: _authHeader(),
    );
    return response.statusCode == 200;
  }

  @override
  Future<void> retryFailedMessage(String messageId) async {
    final msg = _failedMessages[messageId];
    if (msg != null) {
      final success = await sendMessage(chatId: msg.chatId, text: msg.text);
      if (success) _failedMessages.remove(messageId);
    }
  }

  @override
  void clearLocalCache(String conversationId) {
    _failedMessages.removeWhere((key, msg) => msg.chatId == conversationId);
  }

  @override
  Future<void> dispose() async {
    await _wsService.disconnect();
  }

  // Получение заголовка Authorization
  Map<String, String> _authHeader() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_authService.tokens?.jwt ?? ''}',
  };

  /// TODO!!!! НИЧЕГО Не ДЕЛАЕТ НА ДАННЫЙ МОМЕНТ
  @override
  void notice(String? data) {
    // if (data == null) return;
    // final jsonData = jsonDecode(data) as Map<String, dynamic>;
    // switch (jsonData['type']) {
    //   case 'message':
    //     final msg = Message.fromJson(jsonData);
    //     _messageController.add(msg);
    //     break;
    //   case 'typing':
    //   // можно передавать событие индикатора набора
    //     break;
    // // другие типы...
    // }
    print(data);
  }
}


enum MessageAction {VIEWED,NEW,UPDATED,DELETED}

class Message {
  final String id;
  final String chatId;
  String memberId = DummyAuthenticationService().id!;
  final String text;
  final DateTime timestamp;
  final bool isEdited;
  final bool isRead;
  final List<String> viewedBy;

  Message({
    required this.id,
    required this.chatId,
    String? memberId,
    required this.text,
    required this.timestamp,
    this.isEdited = false,
    this.isRead = false,
    this.viewedBy = const [],
  }) : memberId = memberId ?? DummyAuthenticationService().id!;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'],
    chatId: json['chatId'],
    memberId: json['memberId'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    isEdited: json['edited'] ?? false,
    isRead: json['status'] == 'VIEWED',
    viewedBy: List<String>.from(json['viewedBy'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chatId': chatId,
    'memberId': memberId,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'edited': isEdited,
    'status': isRead ? 'VIEWED' : 'NOT_VIEWED',
    'viewedBy': viewedBy,
  };
}