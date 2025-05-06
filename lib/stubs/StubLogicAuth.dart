import 'dart:async';

import '../logic/AuthenticationService.dart';

class DummyAuthenticationService implements AuthenticationService {
  DummyAuthenticationService._internal();
  static final DummyAuthenticationService _instance = DummyAuthenticationService._internal();
  factory DummyAuthenticationService() => _instance;


  AuthTokens? _tokens;

  @override
  AuthTokens? get tokens => _tokens;

  @override
  String? id;

  @override
  String get jwt => _tokens?.jwt ?? '';

  @override
  Future<AuthResult> register({
    required String email,
    required String username,
    String? tag,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    _tokens = AuthTokens(
      jwt: 'dummy_jwt_token',
      refreshToken: 'dummy_refresh_token',
    );
    id = 'dummy_user_id';
    return AuthSuccessLogin(_tokens!);
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    _tokens = AuthTokens(
      jwt: 'dummy_jwt_token',
      refreshToken: 'dummy_refresh_token',
    );
    id = 'dummy_user_id';
    return AuthSuccessLogin(_tokens!);
  }

  @override
  Future<AuthResult> refresh() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (_tokens == null) {
      return AuthFailure('No tokens to refresh');
    }
    _tokens = AuthTokens(
      jwt: 'refreshed_dummy_jwt_token',
      refreshToken: 'refreshed_dummy_refresh_token',
    );
    return AuthSuccessLogin(_tokens!);
  }

  @override
  Future<AuthResult> logout() async {
    await Future.delayed(Duration(milliseconds: 300));
    _tokens = null;
    id = null;
    return AuthSuccessLogout();
  }

  @override
  Future<bool> myId() async {
    await Future.delayed(Duration(milliseconds: 300));
    if(id == null){
      print("пустой айди!!!");
    }
    return id != null;
  }
}
