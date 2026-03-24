import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await repository.isLoggedIn();
    if (isLoggedIn) {
      emit(const AuthAuthenticated(''));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await repository.login(event.mobile, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (token) => emit(AuthAuthenticated(token)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await repository.register(
      event.name,
      event.mobile,
      event.password,
      event.city,
      event.gaushalaName,
      event.totalCattle,
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthRegistered()),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await repository.logout();
    emit(AuthUnauthenticated());
  }
}
