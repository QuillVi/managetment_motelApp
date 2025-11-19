import 'package:dio/dio.dart';
import 'package:motelapp/data/models/service_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ServiceHomeRepository {
  final Dio dio = DioClient().dio;

  Future<List<ServiceModel>> fetchServices() async {
    final response = await dio.get('/service/getlistServices');

    if (response.statusCode == 200 && response.data['success'] == true) {
      List<dynamic> data = response.data['data'];
      return data.map((item) => ServiceModel.fromMap(item)).toList();
    } else {
      throw Exception('Không thể lấy danh sách dịch vụ');
    }
  }

  Future<List<ServiceClosureModel>> fetchClosureServices() async {
    final response = await dio.get('/service/getListServicesClosure');

    if (response.statusCode == 200 && response.data['success'] == true) {
      List<dynamic> data = response.data['data'];
      return data.map((item) => ServiceClosureModel.fromMap(item)).toList();
    } else {
      throw Exception('Không thể lấy danh sách chốt dịch vụ');
    }
  }

  /// Lấy chi tiết một dịch vụ bằng ID
  Future<DetailServiceModel> fetchDetailService(int idDichVu) async {
    // Truyền ID vào đường dẫn
    final response = await dio.get('/service/getDetailService/$idDichVu');

    if (response.statusCode == 200 && response.data['success'] == true) {
      // Dữ liệu API trả về là một List, dù chỉ có 1 phần tử
      List<dynamic> dataList = response.data['data'];

      // Kiểm tra xem List có rỗng không
      if (dataList.isNotEmpty) {
        // Lấy phần tử đầu tiên (duy nhất) trong List
        Map<String, dynamic> item = dataList[0];
        // Chuyển đổi map đó thành model và trả về
        return DetailServiceModel.fromMap(item);
      } else {
        // Xử lý trường hợp API trả về success: true nhưng data: [] (không tìm thấy ID)
        throw Exception('Không tìm thấy dịch vụ');
      }
    } else {
      // Xử lý lỗi từ server
      throw Exception('Không thể lấy chi tiết dịch vụ');
    }
  }

  /// Cập nhật thông tin dịch vụ
  /// [data] là Map chứa các key: id_dichvu, phi_dichvu, ghi_chu, danhSachToaNha
  Future<bool> updateService(Map<String, dynamic> data) async {
    try {
      // Gọi API phương thức PUT (theo backend bạn đã định nghĩa)
      final response = await dio.put(
        '/service/updateService',
        data: data, // Dio sẽ tự động chuyển Map này thành JSON body
      );

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true; // Cập nhật thành công
      } else {
        // Nếu server trả về success: false hoặc lỗi khác
        throw Exception(response.data['message'] ?? 'Lỗi cập nhật dịch vụ');
      }
    } on DioException catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi từ server (400, 404, 500...)
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi kết nối server');
      }
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Xóa một dịch vụ bằng ID
  Future<bool> deleteService(int idDichVu) async {
    try {
      // Gọi API phương thức DELETE
      // Đường dẫn sẽ là: /service/deleteService/123
      final response = await dio.delete('/service/deleteService/$idDichVu');

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true; // Xóa thành công
      } else {
        // Trường hợp server trả về 200 nhưng success: false (ít gặp với delete, nhưng cứ check cho chắc)
        throw Exception(response.data['message'] ?? 'Lỗi xóa dịch vụ');
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ server (ví dụ: 400 Bad Request, 500 Server Error)
      if (e.response != null) {
        // Lấy thông báo lỗi cụ thể từ Backend (ví dụ: "Không thể xóa vì đã có hóa đơn...")
        final message = e.response?.data['message'] ?? 'Lỗi kết nối server';
        throw Exception(message);
      }
      throw Exception('Lỗi không xác định: $e');
    }
  }
}
