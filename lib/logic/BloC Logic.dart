import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:p3/logic/AuthenticationService.dart';
import 'AuthState.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthenticationService authService;

  AuthCubit({required this.authService}) : super(AuthInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(AuthLoading());
    try {
      await authService.init();
      final isLoggedIn = await authService.myId();

      if (isLoggedIn && authService.tokens != null && authService.id != null) {
        emit(AuthAuthenticated(
          tokens: authService.tokens!,
          userId: authService.id!,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Ошибка инициализации: $e'));
    }
  }

  Future<void> register({
    required String email,
    required String username,
    String? tag,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final result = await authService.register(
        email: email,
        username: username,
        tag: tag,
        password: password,
      );

      if (result is AuthSuccessLogin) {
        await authService.myId();
        if (authService.id != null) {
          emit(AuthAuthenticated(
            tokens: result.tokens,
            userId: authService.id!,
          ));
        } else {
          emit(AuthError(message: 'Не удалось получить ID пользователя'));
        }
      } else if (result is AuthFailure) {
        emit(AuthError(message: result.error));
      } else if (result is AuthSuccessLogout) {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Ошибка регистрации: $e'));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final result = await authService.login(
        email: email,
        password: password,
      );

      if (result is AuthSuccessLogin) {
        await authService.myId();
        if (authService.id != null) {
          emit(AuthAuthenticated(
            tokens: result.tokens,
            userId: authService.id!,
          ));
        } else {
          emit(AuthError(message: 'Не удалось получить ID пользователя'));
        }
      } else if (result is AuthFailure) {
        emit(AuthError(message: result.error));
      } else if (result is AuthSuccessLogout) {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Ошибка входа: $e'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final result = await authService.logout();

      if (result is AuthSuccessLogin) {
        // Не должно происходить при выходе
      } else if (result is AuthFailure) {
        emit(AuthError(message: result.error));
      } else if (result is AuthSuccessLogout) {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Ошибка выхода: $e'));
    }
  }

  Future<void> refresh() async {
    try {
      final result = await authService.refresh();

      if (result is AuthSuccessLogin) {
        if (authService.id != null) {
          emit(AuthAuthenticated(
            tokens: result.tokens,
            userId: authService.id!,
          ));
        } else {
          emit(AuthError(message: 'ID пользователя недоступен'));
        }
      } else if (result is AuthFailure) {
        emit(AuthError(message: result.error));
      } else if (result is AuthSuccessLogout) {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: 'Ошибка обновления токена: $e'));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}