import 'package:dio/dio.dart';
import 'package:motelapp/data/models/User_model/contract_user_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class DetailContractUserRepository {
  final Dio dio = DioClient().dio;

  /// Lấy chi tiết hợp đồng của người dùng đang đăng nhập.
  /// Không cần truyền ID vì server sẽ tự lấy từ Token trong Header.
  Future<DetailContractUserModel> fetchDetailContractUser() async {
    try {
      // Endpoint dựa trên controller Node.js bạn cung cấp
      final response = await dio.get('/contract/getDetailContractIdUser');

      // Log để debug dữ liệu trả về
      print('Response Detail Contract: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Map toàn bộ response vào DetailContractUserModel
        // (Bên trong model này đã bao gồm parsing cho ContractData)
        return DetailContractUserModel.fromMap(response.data);
      } else {
        // Xử lý trường hợp success = false hoặc lỗi từ server
        throw Exception(
          response.data['message'] ?? 'Không thể lấy thông tin hợp đồng',
        );
      }
    } catch (e) {
      print('Error fetching contract detail: $e');
      rethrow; // Ném lỗi để Cubit/Bloc/UI xử lý hiển thị thông báo
    }
  }
}
