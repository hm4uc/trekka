import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trekka/features/auth/domain/usecases/login_user.dart';
import 'package:trekka/features/auth/domain/usecases/register_user.dart';
import 'package:trekka/features/auth/presentation/bloc/auth_event.dart';
import 'package:trekka/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
  }

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUser(event.email, event.password);
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
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
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }
}