import 'package:dio/dio.dart';
import 'package:motelapp/data/models/statistical_model.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/services/dio_client.dart';
import 'package:motelapp/core/utils/exceptions.dart';
import 'package:motelapp/data/services/service_locator.dart';
import 'package:motelapp/logic/cubits/auth/auth_cubit.dart';

class StatisticalHomeRepository {
  final Dio dio = DioClient().dio;

  Future<StatisticalModel> fetchStatistics() async {
    // LOẠI BỎ: Không cần kiểm tra token thủ công ở đây nữa (Interceptors đã lo)

    try {
      final respones = await dio.get(
        '/statistical/statistics',
        // LOẠI BỎ: Không cần options: headers: {'Authorization': 'Bearer $token'}
        // nếu dùng Dio Interceptor để đính kèm Token.
      );

      final data = respones.data;
      print('data statictical : ${data}');

      if (data['success'] == true && data['data'] != null) {
        final map = data['data'];
        return StatisticalModel.fromMap(map);
      } else {
        throw Exception(data['message'] ?? 'Lấy thống kê thất bại');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        // 1. KÍCH HOẠT LOGIC HẾT PHIÊN TOÀN CỤC
        // Gọi AuthCubit để xóa token và emit trạng thái SessionExpired (tự động chuyển hướng)
        try {
          final authCubit = getIt<AuthCubit>();
          // Giả định AuthCubit có phương thức này:
          authCubit.handleSessionExpired();
        } catch (_) {
          print('AuthCubit not found in getIt, cannot auto-handle 401.');
        }

        // 2. NÉM EXCEPTION CỤ THỂ
        // Ném SessionExpiredException để StatisticalCubit bắt và dừng load dữ liệu.
        throw SessionExpiredException();
      }

      // Ném lỗi khác nếu không phải 401
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
