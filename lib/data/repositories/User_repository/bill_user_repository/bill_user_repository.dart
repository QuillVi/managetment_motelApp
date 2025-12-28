import 'package:dio/dio.dart';
import 'package:motelapp/data/models/User_model/bill_user_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class BillUserRepository {
  final Dio dio = DioClient().dio;

  Future<List<BillUserModel>> fetchListBillUser() async {
    try {
      // Endpoint: /bill/getListBillUser (giả định base URL trong DioClient đã trỏ đến /api)
      final response = await dio.get('/bill/getListBillUser');

      // In log để debug
      print('Response data User Bill: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        // Map dữ liệu sang List<BillUserModel>
        return data.map((e) => BillUserModel.fromMap(e)).toList();
      } else {
        // Lấy message lỗi từ server nếu có
        throw Exception(
          response.data['message'] ?? 'Không thể lấy danh sách hóa đơn cá nhân',
        );
      }
    } catch (e) {
      print('Error fetching user bills: $e');
      rethrow; // Ném lỗi ra để Cubit/Bloc bên ngoài xử lý
    }
  }

  /// Hàm lấy chi tiết hóa đơn cho User
  Future<DetailBillUserModel> fetchDetailBillUser(int idHoaDon) async {
    try {
      // Gọi API lấy chi tiết.
      // Bạn cần đảm bảo Backend có route này.
      // Cách gọi này gửi param dạng: /bill/getDetailBillUser?id_hoadon=1
      final response = await dio.get('/bill/getDetailBillUser/$idHoaDon');

      // Log để kiểm tra dữ liệu trả về
      print('Response Detail User: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic data = response.data['data'];

        // Xử lý trường hợp data trả về là List (do query SQL) hoặc Map
        if (data is List) {
          if (data.isNotEmpty) {
            return DetailBillUserModel.fromMap(data[0]);
          } else {
            throw Exception('Không tìm thấy dữ liệu hóa đơn này');
          }
        } else if (data is Map<String, dynamic>) {
          return DetailBillUserModel.fromMap(data);
        } else {
          throw Exception('Định dạng dữ liệu không hợp lệ');
        }
      } else {
        throw Exception(
          response.data['message'] ?? 'Lỗi khi tải chi tiết hóa đơn',
        );
      }
    } catch (e) {
      print('Error fetching detail bill user: $e');
      rethrow; // Ném lỗi để Cubit xử lý
    }
  }
}
