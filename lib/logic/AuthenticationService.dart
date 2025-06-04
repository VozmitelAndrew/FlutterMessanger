import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthenticationService {
  Future<AuthResult> register({
    required String email,
    required String username,
    String? tag,
    required String password,
  });

  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> refresh();
  Future<AuthResult> logout();
  Future<bool> myId();

  AuthTokens? get tokens;
  String? id;
  String get jwt;
}

class AuthTokens {
  final String jwt;
  final String refreshToken;

  AuthTokens({required this.jwt, required this.refreshToken});
}

sealed class AuthResult {
  const factory AuthResult.successLogin(AuthTokens tokens) = AuthSuccessLogin;
  const factory AuthResult.failure(String error) = AuthFailure;
  const factory AuthResult.successLogout() = AuthSuccessLogout;
}

class HttpAuthService implements AuthenticationService {
  HttpAuthService._internal();
  static final HttpAuthService _instance = HttpAuthService._internal();
  factory HttpAuthService() => _instance;

  final String _baseUrl = 'http://localhost:8080';
  AuthTokens? _tokens;
  String? _email;

  int refreshAttempts = 0;


  // Вызывать один раз при старте приложения, ДО любых вызовов login/register.
  // Если в SharedPreferences найдены jwt+refresh+email, они будут загружены в _tokens/_email.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJwt = prefs.getString('auth_jwt');
    final savedRefresh = prefs.getString( 'auth_refresh');
    final savedEmail = prefs.getString('auth_email');

    if (savedJwt != null && savedRefresh != null && savedEmail != null) {
      _tokens = AuthTokens(jwt: savedJwt, refreshToken: savedRefresh);
      _email = savedEmail;
      await myId();
    }
  }




  Future<void> _saveTokensToPrefs({
    required String jwt,
    required String refreshToken,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_jwt', jwt);
    await prefs.setString( 'auth_refresh', refreshToken);
    await prefs.setString('auth_email', email);
  }


  Future<void> _clearTokensFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_jwt');
    await prefs.remove( 'auth_refresh');
    await prefs.remove('auth_email');
  }







  @override
  Future<AuthResult> register({
    required String email,
    required String username,
    String? tag,
    required String password,
  }) async {
    _email = email;
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

      return _responseHandler(response);
    } catch (e) {
      return AuthResult.failure('Ошибка сети или сервера при регистрации: $e');
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _email = email;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signin'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      return _responseHandler(response);
    } catch (e) {
      return AuthResult.failure('Ошибка сети или сервера при входе: $e');
    }
  }

  @override
  Future<AuthResult> refresh() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': _email!,
          'refresh': _tokens!.refreshToken,
        }),
      );

      return _responseHandler(response);
    } catch (e) {
      return AuthResult.failure('Ошибка при обновлении токена: $e');
    }
  }

  @override
  Future<AuthResult> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signout'),
      );

      //Предполагаю, что обнуление email может привести к ошибкам с refresh. Ну будем верить что я умний и не будет nullexception :D
      _email = null;
      _tokens = null;
      _clearTokensFromPrefs();


      id = null;

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult.successLogout();
      }
      else{
        return AuthResult.failure(
          data['error'] ?? 'Ошибка обработки выхода: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult.failure('Ошибка сети или сервера при выходе из аккаунта: $e');
    }
  }

  //TODO - упаковать в отдельный класс и сделать через call()? Ну пока слишком мало функционала - сойдёт за обычный метод.
  Future<AuthResult> _responseHandler(http.Response response) async {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? refresh = data['refresh'];
      final String? jwt = data['jwt'];

      if (refresh != null && jwt != null) {
        _tokens = AuthTokens(jwt: jwt, refreshToken: refresh);

        _saveTokensToPrefs(email: _email!, jwt: jwt, refreshToken: refresh);
        if(id == null){
          await myId();
        }

        refreshAttempts = 0;
        return AuthResult.successLogin(_tokens!);
      } else {
        print('Ошибка обработки - токен пуст');
        return AuthResult.failure('Ошибка обработки - токен пуст');
      }
    }else if(response.statusCode == 404 || refreshAttempts < 3){
      ++refreshAttempts;
      return refresh();
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('Ошибка обработки: ${response.statusCode}');
      return AuthResult.failure(
        data['error'] ?? 'Ошибка обработки: ${response.statusCode}',
      );
    }
  }

  @override
  AuthTokens? get tokens => _tokens;

  @override
  String get jwt {
    if (_tokens == null) {
      throw Exception('JWT token пуст при попытке предоставления!');
    }
    return _tokens?.jwt ?? '';
  }

  @override
  String? id;

  //TODO рефактор myId на myInfo, создание структуры MiInfo внутри AuthService
  @override
  Future<bool> myId() async {
    print(jwt);
    print(tokens!.refreshToken);
    if(id == null){
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'),
        headers: _authHeader(),
      );
      print(response.statusCode);
      if(response.statusCode != 200){
        print(response.statusCode);
        print(response.body);
        return false;
      }
      final Map<String, dynamic> data = jsonDecode(response.body);
      id = data['id'];
    }
    print('id');
    return true;
  }

  Map<String, String> _authHeader() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${tokens?.jwt ?? ''}',
  };

}

class AuthSuccessLogin implements AuthResult {
  final AuthTokens tokens;
  const AuthSuccessLogin(this.tokens);
}

class AuthFailure implements AuthResult {
  final String error;
  const AuthFailure(this.error);
}

class AuthSuccessLogout implements AuthResult {
  const AuthSuccessLogout();
}
