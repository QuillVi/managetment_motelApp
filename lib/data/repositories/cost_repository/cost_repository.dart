import 'package:dio/dio.dart';
import 'package:motelapp/data/models/cost_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class CostRepository {
  final Dio dio = DioClient().dio;

  Future<List<CostModel>> fetchListCost() async {
    final response = await dio.get('/cost/getListCost');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => CostModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách khoản thu');
    }
  }

  // Trong CostRepository.dart

  Future<CostDetailModel> fetchCostDetail(int idHoaDon) async {
    final response = await dio.get('/cost/getDetailCost/$idHoaDon');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      // 1. Nhận về là List
      final List<dynamic> dataList = response.data['data'];

      // 2. Kiểm tra xem List có rỗng không
      if (dataList.isEmpty) {
        throw Exception('Không tìm thấy chi tiết khoản thu');
      }

      // 3. Lấy phần tử đầu tiên (là Map)
      final Map<String, dynamic> data = dataList[0] as Map<String, dynamic>;

      return CostDetailModel.fromMap(data);
      // KẾT THÚC THAY ĐỔI
    } else {
      throw Exception('Không thể lấy chi tiết khoản thu');
    }
  }
}
