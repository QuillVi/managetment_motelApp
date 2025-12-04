import 'package:dio/dio.dart';
import 'package:motelapp/data/models/problem_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class DetailProblemRepository {
  final Dio dio = DioClient().dio;

  Future<DetailProblemModel> fetchDetailProblem(int idSuco) async {
    final response = await dio.get('/problem/getDetailProblem/$idSuco');
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

  Future<bool> completeProblem(int idSuco) async {
    try {
      // Gọi API PUT theo đường dẫn bạn cung cấp
      final response = await dio.put('/problem/completeProblem/$idSuco');

      print('Complete Problem Response: ${response.data}');

      // Kiểm tra success == true từ JSON trả về
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true; // Trả về true nếu thành công
      } else {
        // Lấy message lỗi từ server nếu có
        final message = response.data['message'] ?? 'Thao tác thất bại';
        throw Exception(message);
      }
    } catch (e) {
      print("Lỗi khi hoàn thành sự cố: $e");
      rethrow; // Ném lỗi ra để Cubit/Bloc xử lý
    }
  }
}
