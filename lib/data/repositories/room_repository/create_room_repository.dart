import 'package:dio/dio.dart';
import 'package:motelapp/data/services/dio_client.dart';

class CreateRoomRepository {
  final Dio dio = DioClient().dio;

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post('/room/createRoom', data: payload);

      final data = response.data;

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          print("✅ Tạo phòng thành công: $data");
          return data;
        } else {
          print("⚠️ API trả về success=false: $data");
          throw Exception("API báo lỗi: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        print("⚠️ API trả về statusCode ${response.statusCode}: $data");
        throw Exception("Không thể thêm dịch vụ");
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
