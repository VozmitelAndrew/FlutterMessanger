import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class AuthenticationService {
  Future<AuthResult> register({
    required String email,
    required String username,
    String? tag,
    required String password,
  });

  Future<AuthResult> login({required String email, required String password});
}

class HttpAuthService implements AuthenticationService {
  final String _baseUrl;

  HttpAuthService(this._baseUrl);

  @override
  Future<AuthResult> register({
    required String email,
    required String username,
    String? tag,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': email,
          'username': username,
          'tag': tag ?? username,
          'password': password,
        }),
      );

      return responceHandler(response);
    } catch (e) {
      return AuthResult.failure('Ошибка сети или сервера при регистрации: $e');
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signin'), // Полный URL для логина
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      return responceHandler(response);
    } catch (e) {
      return AuthResult.failure('Ошибка сети или сервера при входе: $e');
    }
  }

  //TODO - упаковать в отдельный класс и сделать через call()? Ну пока слишком мало функционала - сойдёт за обычный метод.
  AuthResult responceHandler(http.Response response) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? refresh = data['refresh'];
      final String? jwt = data['jwt'];
      if (refresh != null && jwt != null) {
        return AuthResult.success(refresh, jwt);
      } else {
        return AuthResult.failure('Ошибка обработки - токен пуст');
      }
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResult.failure(
        data['error'] ?? 'Ошибка обработки: ${response.statusCode}',
      );
    }
  }
}

class AuthResult {
  String? refresh;
  String? jwt;
  String? errorMessage;

  bool get isSuccess => (jwt != null && refresh != null);

  bool get isFailure => errorMessage != null;

  AuthResult.success(this.refresh, this.jwt);

  AuthResult.failure(this.errorMessage);
}

//
// class AuthResult {
//   String? refresh;
//   String? jwt;
//   bool loggedOff = false;
//   String? errorMessage;
//
//   bool get isSuccess => (jwt != null || loggedOff);
//   bool get isFailure => errorMessage != null;
//
//   AuthResult.success(this.refresh, this.jwt);
//   AuthResult.failure(this.errorMessage);
//   AuthResult.exit(): loggedOff = true;
// }
