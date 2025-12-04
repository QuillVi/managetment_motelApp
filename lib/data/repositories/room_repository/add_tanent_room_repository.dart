import 'package:dio/dio.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class AddTanentRoomRepository {
  final Dio dio = DioClient().dio;

  Future<Map<String, dynamic>> addTanentRoom(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post('/room/addTenantInRoom', data: payload);

      final data = response.data;

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          print("✅ Thêm người thuê thành công: $data");
          return data;
        } else {
          print("⚠️ API trả về success=false: $data");
          throw Exception("API báo lỗi: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        print("⚠️ API trả về statusCode ${response.statusCode}: $data");
        throw Exception("Không thể thêm người thuê");
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

  Future<List<SelectRoomIDManagetModel>> fetchListRoomByIDManager() async {
    final response = await dio.get('/room/getListRoomByManager');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => SelectRoomIDManagetModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách phòng');
    }
  }

  Future<Map<String, dynamic>> addTanentRoomFunctionHome(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/room/addTenantFunctionHome',
        data: payload,
      );

      final data = response.data;

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          print("✅ Thêm người thuê thành công: $data");
          return data;
        } else {
          print("⚠️ API trả về success=false: $data");
          throw Exception("API báo lỗi: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        print("⚠️ API trả về statusCode ${response.statusCode}: $data");
        throw Exception("Không thể tạo dịch vụ");
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
