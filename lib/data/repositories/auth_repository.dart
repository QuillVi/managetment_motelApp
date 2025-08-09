import 'package:dio/dio.dart';
import 'package:motelapp/data/models/user_model.dart';
import 'package:motelapp/data/services/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  /// ✅ Đăng nhập
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;

      if (data['success'] == true && data['user'] != null) {
        final user = UserModel.fromMap(data['user']);
        await saveUserData(
          id: int.parse(user.id_nguoidung),
          email: user.email,
          ten: user.ten ?? '',
          vaitro: user.vaitro ?? '',
          token: user.token ?? '',
        );
        return user;
      } else {
        throw Exception(data['message'] ?? 'Đăng nhập thất bại');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi mạng');
    }
  }

  /// ✅ Đăng ký
  Future<UserModel> register({
    required String ten,
    required String ngaysinh,
    required String sdt,
    required String diachi,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'ten': ten,
        'ngaysinh': ngaysinh,
        'sdt': sdt,
        'diachi': diachi,
        'email': email,
        'password': password,
      });

      final data = response.data;

      if (data['success'] == true && data['user'] != null) {
        final user = UserModel.fromMap(data['user']);
        await saveUserData(
          id:int.parse(user.id_nguoidung),
          email: user.email,
          ten: user.ten ?? '',
          vaitro: user.vaitro ?? '',
          token: user.token ?? '',
        );
        return user;
      } else {
        throw Exception(data['message'] ?? 'Đăng ký thất bại');
      }
    } on DioError catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi mạng');
    }
  }

  /// ✅ Lưu thông tin người dùng
  Future<void> saveUserData({
    required int id,
    required String email,
    required String ten,
    required String vaitro,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
    await prefs.setString('email', email);
    await prefs.setString('ten', ten);
    await prefs.setString('vaitro', vaitro);
    await prefs.setString('token', token);
  }

  /// ✅ Xoá thông tin khi đăng xuất
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
    await prefs.remove('email');
    await prefs.remove('ten');
    await prefs.remove('vaitro');
    await prefs.remove('token');
  }

  /// ✅ Lấy token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// ✅ Các getter khác
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ten');
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('vaitro');
  }
}
