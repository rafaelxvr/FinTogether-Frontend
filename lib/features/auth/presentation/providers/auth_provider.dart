import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final SyncManager syncManager;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.syncManager,
  }) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => state = const AuthUnauthenticated(),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    final result = await loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (authResult) {
        state = AuthAuthenticated(authResult.user);
        syncManager.initialFullPull();
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String locale = 'pt-BR',
  }) async {
    state = const AuthLoading();

    final result = await registerUseCase(
      name: name,
      email: email,
      password: password,
      locale: locale,
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (authResult) {
        state = AuthAuthenticated(authResult.user);
        syncManager.initialFullPull();
      },
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();

    await syncManager.clearAllData();
    final result = await logoutUseCase();

    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  Future<void> forgotPassword(String email) async {
    final result = await forgotPasswordUseCase(email: email);

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final result = await resetPasswordUseCase(
      token: token,
      newPassword: newPassword,
    );

    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => null,
    );
  }

  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
    getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
    resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    syncManager: getIt<SyncManager>(),
  );
});
