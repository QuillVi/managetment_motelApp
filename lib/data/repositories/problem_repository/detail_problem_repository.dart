import 'package:dio/dio.dart';
import 'package:motelapp/data/models/problem_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class DetailProblemRepository {
  final Dio dio = DioClient().dio;

  Future<DetailProblemModel> fetchDetailProblem(int id_suco) async {
    final response = await dio.get('/problem/getDetailProblem/$id_suco');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];

      if (data is List && data.isNotEmpty) {
        // Lấy phần tử đầu tiên trong danh sách
        final firstItem = Map<String, dynamic>.from(data.first);
        return DetailProblemModel.fromMap(firstItem);
      } else if (data is Map<String, dynamic>) {
        // Trường hợp backend chỉ trả 1 object
        return DetailProblemModel.fromMap(data);
      } else {
        throw Exception('Dữ liệu trả về không đúng định dạng');
      }
    } else {
      throw Exception('Không thể lấy chi tiết sự cố');
    }
  }
}
