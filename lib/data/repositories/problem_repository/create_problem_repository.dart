import 'package:dio/dio.dart';
import 'package:motelapp/data/services/dio_client.dart';

class CreateProblemRepository {
  final Dio dio = DioClient().dio;

  Future<Map<String, dynamic>> createProblem(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post('/problem/createProblem', data: payload);
      final data = response.data;

      if (response.statusCode == 201) {
        if (data['message'] != null && data['newId'] != null) {
          print(
            "✅ Tạo sự cố thành công: ${data['message']} (ID: ${data['newId']})",
          );
          return data;
        } else {
          print("⚠️ API trả về 201 nhưng thiếu dữ liệu: $data");
          throw Exception(
            "Phản hồi thành công nhưng thiếu dữ liệu. Message: ${data['message']}",
          );
        }
      } else {
        print("⚠️ API trả về statusCode ${response.statusCode}: $data");
        throw Exception("Không thể tạo sự cố");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("❌ Lỗi API: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
        print("❌ Lỗi mạng hoặc cấu hình: ${e.message}");
      }
      throw Exception("Lỗi khi gọi API: ${e.message}");
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      throw Exception("Lỗi không xác định: $e");
    }
  }
}
