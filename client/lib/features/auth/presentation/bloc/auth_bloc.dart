import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/register_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginUseCase;
  final RegisterWithEmail registerUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthRegisterSubmitted>(_onRegister);
    on<AuthCheckRequested>(_onCheckAuth);
  }

  Future<void> _onLogin(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)), // Trả về lỗi từ Server
      (user) => emit(AuthSuccess(user)), // Trả về User thành công
    );
  }

  Future<void> _onRegister(AuthRegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(
        RegisterParams(fullname: event.fullname, email: event.email, password: event.password));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onCheckAuth(AuthCheckRequested event, Emitter<AuthState> emit) async {
    // Không emit Loading để tránh nháy màn hình Splash
    final result = await authRepository.checkAuthStatus();
    result.fold(
      (failure) => emit(AuthInitial()), // Chưa đăng nhập -> Về trạng thái đầu
      (user) => emit(AuthSuccess(user)), // Đã đăng nhập -> Trả về User
    );
  }
}
