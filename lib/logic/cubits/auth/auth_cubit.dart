import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/models/user_model.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/services/fcm_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final FcmService fcmService;

  AuthCubit({required this.authRepository, required this.fcmService})
    : super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      // 1. Đăng nhập thành công
      final user = await authRepository.login(email: email, password: password);

      // 2. ✨ GỌI FCM SERVICE ĐỂ GỬI TOKEN LÊN SERVER
      try {
        final fcmToken = await fcmService.getFcmToken();
        if (fcmToken != null) {
          // Dùng repo để gọi API
          await authRepository.updateFcmToken(fcmToken);
        }
      } catch (e) {
        print("FCM Token Error: $e");
        // Không emit lỗi ở đây để tránh làm gián đoạn luồng đăng nhập
      }

      // 3. Cập nhật trạng thái đăng nhập thành công (giữ nguyên)
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
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
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  Future<void> logout() async {
    // (Khuyến nghị) Gửi token rỗng lên server để báo thiết bị này không
    // muốn nhận thông báo nữa, trước khi đăng xuất
    try {
      await authRepository.updateFcmToken(""); // Gửi một token rỗng
    } catch (e) {
      // Bỏ qua lỗi
    }

    // Xóa dữ liệu local
    await authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> handleSessionExpired() async {
    // 1. Xóa token và dữ liệu user cục bộ (signOut thường làm điều này)
    await authRepository.signOut();

    // 2. EMIT TRẠNG THÁI SESSION EXPIRED
    // Đây là trạng thái mà BlocListener ở Widget gốc sẽ lắng nghe để tự động chuyển hướng
    emit(const AuthState(status: AuthStatus.sessionExpired));
  }

  //  // Trong class AuthCubit
  Future<void> tryAutoLogin() async {
    final token = await authRepository.getToken();
    // Lấy thêm các trường cần thiết
    final id = await authRepository.getUserId();
    final ten = await authRepository.getUserName();
    final email = await authRepository.getUserEmail(); // Nên lấy cả email
    final vaitro = await authRepository.getUserRole(); // Nên lấy cả vai trò

    if (token != null && id != null) {
      // Đảm bảo có cả token và id
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel(
            // Sửa: Dùng id đã lấy từ SharedPreferences (chuyển int thành String)
            id_nguoidung: id.toString(),
            // Sửa: Dùng các trường đã lấy từ SharedPreferences
            email: email ?? '',
            ten: ten ?? 'Người dùng',
            vaitro: vaitro ?? '',
            token: token,
            // Các trường tùy chọn khác có thể để null
          ),
        ),
      );
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
