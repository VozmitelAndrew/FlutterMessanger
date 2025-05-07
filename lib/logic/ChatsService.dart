import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'AuthenticationService.dart';
import 'WebSocketService.dart';

abstract class ChatsService {
  Future<Chat> createChat({required String name});

  Future<List<Chat>> getChats();

  Future<bool> updateChat({required String chatId, required String newName});

  Future<bool> deleteChat({required String chatId});

  Future<Member?> addMember({
    required String chatId,
    required String tag,
    required Role role,
  });

  Future<bool> deleteMember({required String chatId, required String memberId});
}

class HTTPChatsService implements ChatsService {
  HTTPChatsService._internal();

  static final HTTPChatsService _instance = HTTPChatsService._internal();

  factory HTTPChatsService() => _instance;

  final String _baseUrl = 'http://localhost:8080';
  final AuthenticationService _authService = HttpAuthService();
  final WebSocketServiceImpl _wsService = WebSocketServiceImpl();

  /// Создание нового чата
  @override
  Future<Chat> createChat({required String name}) async {
    print(name);
    final uri = Uri.parse('$_baseUrl/chats');
    final response = await http.post(
      uri,
      headers: _authHeader(),
      body: jsonEncode({'name': name}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final chat = Chat.fromJson(data);
      return chat;
    }
    throw Exception('Ошибка создания чата: ${response.statusCode}');
  }

  /// Получение списка доступных чатов
  @override
  Future<List<Chat>> getChats() async {
    print("птыюась получить список чатов");
    final uri = Uri.parse('$_baseUrl/chats');
    final response = await http.get(uri, headers: _authHeader());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data.map((e) => Chat.fromJson(e)).toList();
    }
    print(response.body);

    throw Exception('Ошибка получения списка чатов: ${response.statusCode}');
  }

  /// Обновление названия чата
  @override
  Future<bool> updateChat({
    required String chatId,
    required String newName,
  }) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId');
    final response = await http.put(
      uri,
      headers: _authHeader(),
      body: jsonEncode({'name': newName}),
    );
    if (response.statusCode != 200) {
      return false;
    }
    // йиппи
    return true;
  }

  /// Удаление чата (только админ)
  @override
  Future<bool> deleteChat({required String chatId}) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId');
    final response = await http.delete(uri, headers: _authHeader());
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    return false;
  }

  @override
  Future<Member?> addMember({
    required String chatId,
    required String tag,
    required Role role,
  }) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId/users');
    final response = await http.post(
      uri,
      headers: _authHeader(),
      body: jsonEncode({'tag': tag, 'role': role}),
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      //TODO адекватная обработка пользователя
      //Поменять возврат на Member
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Member.fromJson(data);
    }
    return null;
  }

  @override
  Future<bool> deleteMember({
    required String chatId,
    required String memberId,
  }) async {
    final uri = Uri.parse('$_baseUrl/chats/$chatId//members/$memberId');
    final response = await http.delete(uri, headers: _authHeader());
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    return false;
  }

  /// Заголовки для авторизации
  Map<String, String> _authHeader() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_authService.tokens?.jwt ?? ''}',
  };
}

enum Role {
  member('MEMBER'),
  admin('ADMIN');

  final String value;

  const Role(this.value);
}

enum Activity {
  inactive('INACTIVE'),
  active('ACTIVE');

  final String value;

  const Activity(this.value);
}

class Member {
  final String memberId;
  String username;
  Role role;
  Activity activity;

  Member({
    required this.memberId,
    required this.username,
    required this.role,
    required this.activity,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    memberId: json['memberId'],
    username: json['username'],
    role: Role.values.firstWhere((e) => e.value == json['role']),
    activity: Activity.values.firstWhere((e) => e.value == json['activity']),
  );

  Map<String, dynamic> toJson() => {
    'memberId': memberId,
    'username': username,
    'role': role.value,
    'activity': activity.value,
  };
}

/// Модель чата
class Chat {
  final String chatId;
  String name;
  int membersQuantity;

  Chat({
    required this.name,
    required this.chatId,
    required this.membersQuantity,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    chatId: json['chatId'],
    name: json['name'],
    membersQuantity: json['membersQuantity'],
  );

  Map<String, dynamic> toJson() => {'chatId': chatId, 'name': name};
}
