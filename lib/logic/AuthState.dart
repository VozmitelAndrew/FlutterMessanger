// auth_state.dart
import 'package:flutter/cupertino.dart';

import 'AuthenticationService.dart';



@immutable
sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthTokens tokens;
  final String userId;

  AuthAuthenticated({
    required this.tokens,
    required this.userId,
  });
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}