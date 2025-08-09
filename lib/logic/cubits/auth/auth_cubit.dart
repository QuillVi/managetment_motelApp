import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/user_model.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit({required this.authRepository}) : super(const AuthState());

  Future<void> login({
  required String email,
  required String password,
}) async {
  emit(state.copyWith(status: AuthStatus.loading));
  try {
    final user = await authRepository.login(
      email: email,
      password: password,
    );
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      error: null,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: AuthStatus.error,
      error: e.toString(),
    ));
  }
}
  Future<void> register({
    required String ten,
    required String ngaysinh,
    required String sdt,
    required String diachi,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await authRepository.register(
        email: email,
        password: password,
        ten: ten,
        ngaysinh: ngaysinh,
        sdt: sdt,
        diachi: diachi,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

 Future<void> tryAutoLogin() async {
  final token = await authRepository.getToken();
  final ten = await authRepository.getUserName();

  if (token != null) {
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      user: UserModel(
        id_nguoidung: '',     
        email: '',            
        ten: ten ?? 'Người dùng',
        vaitro: '',           
        token: token,
      ),
    ));
  } else {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}




  
}
