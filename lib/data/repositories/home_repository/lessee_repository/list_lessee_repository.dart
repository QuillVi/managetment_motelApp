import 'package:dio/dio.dart';
import 'package:motelapp/data/models/lessee_model.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListLesseeRepository {
  final Dio dio = DioClient().dio;
  final AuthRepository _authRepository = AuthRepository();

  Future<List<LesseeModel>> fetchTenants() async {
    final token = await _authRepository.getToken();

    if (token == null) {
      // Ném một ngoại lệ tùy chỉnh để UI dễ dàng xử lý (ví dụ: chuyển đến màn hình đăng nhập)
      throw Exception(
        'Authorization Error: Token is not available. Please log in again.',
      );
    }

    // Khai báo Base URL và Endpoint
    const String endpoint = '/user/getListLessee';

    try {
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {
            // Thiết lập Header Authorization (chú ý: phải có 'Bearer ')
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Kiểm tra trạng thái và success flag
      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        // Sử dụng List.from hoặc data as List<dynamic> an toàn hơn
        return List<LesseeModel>.from(data.map((e) => LesseeModel.fromMap(e)));
      }
      // Xử lý trường hợp statusCode là 200 nhưng success: false (Business Logic Error)
      else if (response.data is Map && response.data['message'] != null) {
        throw Exception(response.data['message']); // Ném thông báo lỗi từ BE
      }
      // Xử lý các trường hợp còn lại
      else {
        throw Exception(
          'Failed to load tanent. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Xử lý các lỗi Dio (mất mạng, timeout, lỗi 401, 403, 500...)
      String errorMessage = 'Network/Server Error';

      if (e.response != null) {
        // Lỗi từ Server (ví dụ: 401 Unauthorized, 403 Forbidden)
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          errorMessage =
              'Authentication/Authorization failed. ${e.response?.data?['message'] ?? ''}';
        } else {
          errorMessage =
              'Server responded with status ${e.response?.statusCode}';
        }
      } else {
        // Lỗi mạng (kết nối)
        errorMessage = 'Connection Error: ${e.message}';
      }

      // Ném ngoại lệ Dio cho layer trên (Service/ViewModel) xử lý
      throw Exception(errorMessage);
    } catch (e) {
      // Xử lý các lỗi khác
      throw Exception('An unknown error occurred: $e');
    }
  }
}
