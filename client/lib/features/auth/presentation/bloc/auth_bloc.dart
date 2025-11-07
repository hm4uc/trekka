import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trekka/core/error/failures.dart';
import 'package:trekka/features/auth/domain/usecases/login_user.dart';
import 'package:trekka/features/auth/domain/usecases/register_user.dart';
import 'package:trekka/features/auth/presentation/bloc/auth_event.dart';
import 'package:trekka/features/auth/presentation/bloc/auth_state.dart';

import '../../../../core/storage/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LocalStorageService localStorageService;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.localStorageService,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<CheckRememberMeEvent>(_onCheckRememberMeEvent);
    on<LogoutEvent>(_onLogoutEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await loginUser(event.email, event.password);

      // Handle the result without using fold with async callbacks
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw Exception());
        final errorMessage = _getErrorMessageFromFailure(failure);
        emit(AuthError(errorMessage));
      } else {
        final user = result.fold((l) => throw Exception(), (r) => r);

        // Save token if login successful
        if (user.token != null) {
          await LocalStorageService.saveToken(user.token!);
        }

        // Handle remember me
        if (event.rememberMe) {
          await LocalStorageService.saveRememberMeCredentials(event.email, event.password);
        } else {
          await LocalStorageService.clearRememberMeCredentials();
        }

        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.'));
    }
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final result = await registerUser(
        usrFullname: event.usrFullname,
        usrEmail: event.usrEmail,
        password: event.password,
        usrGender: event.usrGender,
        usrAge: event.usrAge,
        usrJob: event.usrJob,
        usrPreferences: event.usrPreferences,
        usrBudget: event.usrBudget,
      );

      // Handle the result without using fold with async callbacks
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => throw Exception());
        final errorMessage = _getErrorMessageFromFailure(failure);
        emit(AuthError(errorMessage));
      } else {
        final user = result.fold((l) => throw Exception(), (r) => r);

        // Save token if registration successful
        if (user.token != null) {
          await LocalStorageService.saveToken(user.token!);
        }
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.'));
    }
  }

  Future<void> _onCheckRememberMeEvent(CheckRememberMeEvent event, Emitter<AuthState> emit) async {
    try {
      final credentials = await LocalStorageService.getRememberedCredentials();
      if (credentials['email'] != null && credentials['password'] != null) {
        emit(RememberMeLoaded(
          email: credentials['email']!,
          password: credentials['password']!,
        ));
      }
    } catch (e) {
      // Silently fail for remember me check
      print('Error checking remember me: $e');
    }
  }

  Future<void> _onLogoutEvent(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await LocalStorageService.clearToken();
      await LocalStorageService.clearRememberMeCredentials();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError('Đăng xuất thất bại. Vui lòng thử lại.'));
    }
  }

  String _getErrorMessageFromFailure(Failure failure) {
    if (failure is ServerFailure) {
      switch (failure.statusCode) {
        case 400:
          return 'Thông tin không hợp lệ. Vui lòng kiểm tra lại.';
        case 401:
          return 'Email hoặc mật khẩu không chính xác.';
        case 409:
          return 'Email đã được sử dụng. Vui lòng chọn email khác.';
        case 500:
          return 'Lỗi máy chủ. Vui lòng thử lại sau.';
        default:
          return failure.message;
      }
    }
    return failure.message;
  }
}