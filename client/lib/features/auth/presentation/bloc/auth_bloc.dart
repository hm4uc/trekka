import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/update_profile.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginUseCase;
  final RegisterWithEmail registerUseCase;
  final AuthRepository authRepository;
  final Logout logoutUseCase;
  final UpdateProfile updateProfileUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.authRepository,
    required this.logoutUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthRegisterSubmitted>(_onRegister);
    on<AuthCheckRequested>(_onCheckAuth);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthGetProfileRequested>(_onGetProfile);
    on<AuthUpdateProfileSubmitted>(_onUpdateProfile);
  }

  Future<void> _onLogin(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      // Đăng nhập -> Người dùng cũ -> isNewUser = false
      (user) => emit(AuthSuccess(user, isNewUser: false)),
    );
  }

  Future<void> _onRegister(AuthRegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(
        RegisterParams(fullname: event.fullname, email: event.email, password: event.password));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      // Đăng ký -> Người dùng mới -> isNewUser = true
      (user) => emit(AuthSuccess(user, isNewUser: true)),
    );
  }

  Future<void> _onCheckAuth(AuthCheckRequested event, Emitter<AuthState> emit) async {
    // Không emit Loading để tránh nháy màn hình Splash

    final result = await authRepository.checkAuthStatus();

    result.fold(
      (failure) => emit(AuthInitial()),
      // Tự động đăng nhập -> Người dùng cũ -> isNewUser = false
      (user) => emit(AuthSuccess(user, isNewUser: false)),
    );
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) {
        // Dù lỗi API thì Repository cũng đã clear cache rồi,
        // nên ta vẫn emit AuthInitial để UI chuyển về màn Login.
        // Có thể emit AuthFailure để hiện thông báo rồi mới về Initial nếu muốn kỹ hơn.
        emit(AuthInitial());
      },
      (_) => emit(AuthInitial()), // Thành công -> Về trạng thái chưa đăng nhập
    );
  }

  Future<void> _onGetProfile(AuthGetProfileRequested event, Emitter<AuthState> emit) async {
    // Tùy chọn: Emit loading nếu muốn hiện vòng quay khi vào profile
    // emit(AuthLoading());

    // Gọi hàm này sẽ kích hoạt luồng: Lấy Token -> Gọi API GET /user/profile -> Update Cache
    final result = await authRepository.checkAuthStatus();

    result.fold(
      (failure) {
        // Nếu lỗi (ví dụ hết hạn token), có thể emit AuthInitial để logout
        // Hoặc giữ nguyên state cũ và báo lỗi nhẹ
        if (failure.message.contains('401')) {
          emit(AuthInitial());
        }
      },
      (user) => emit(AuthSuccess(user)), // Cập nhật User mới nhất vào State
    );
  }

  Future<void> _onUpdateProfile(AuthUpdateProfileSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading()); // Show loading

    final result = await updateProfileUseCase(UpdateProfileParams(
      fullname: event.fullname,
      gender: event.gender,
      ageGroup: event.ageGroup,
      bio: event.bio,
      avatar: event.avatar,
    ));

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)), // Update thành công -> Emit user mới -> UI tự cập nhật
    );
  }
}
