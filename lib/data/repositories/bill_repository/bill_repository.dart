import 'package:dio/dio.dart';
import 'package:motelapp/data/models/bill_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class BillRepository {
  final Dio dio = DioClient().dio;

  Future<List<BillModel>> fetchListBill() async {
    final response = await dio.get('/bill/getListBill');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => BillModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách hóa đơn');
    }
  }

  Future<DetailBillModel> fetchDetailBill(int idHoaDon) async {
    final response = await dio.get('/bill/getDetailBill/$idHoaDon');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];

      if (data is List && data.isNotEmpty) {
        // Lấy phần tử đầu tiên trong danh sách
        final firstItem = Map<String, dynamic>.from(data.first);
        return DetailBillModel.fromMap(firstItem);
      } else if (data is Map<String, dynamic>) {
        // Trường hợp backend chỉ trả 1 object
        return DetailBillModel.fromMap(data);
      } else {
        throw Exception('Dữ liệu trả về không đúng định dạng');
      }
    } else {
      throw Exception('Không thể lấy chi tiết Hóa đơn');
    }
  }

  Future<void> updateBill(Map<String, dynamic> billDetails) async {
    try {
      final response = await dio.put(
        '/bill/updateInvoice',
        data: {'hoa_don_details': billDetails},
      );

      print('Update Bill Response: ${response.data}');

      // Xử lý Response (tương tự như các hàm khác)
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data;

        if (response.statusCode == 200 && data['success'] == true) {
          // Thành công
          return;
        } else {
          // Lỗi từ server (vd: success: false)
          final message = data['message'] ?? 'Lỗi cập nhật hóa đơn';
          throw Exception(message);
        }
      } else {
        // Server trả về không phải JSON Map
        throw Exception('Server trả về định dạng dữ liệu không mong đợi.');
      }
    } on DioException catch (e) {
      // Xử lý Lỗi Dio (404, 500, timeout)
      print('DioError updateBill: $e');
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> errorData = e.response!.data;
        if (errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Lỗi kết nối: Không thể cập nhật hóa đơn.');
    } catch (e) {
      // Các lỗi khác
      print('Error updateBill: $e');
      throw Exception(e.toString());
    }
  }

  Future<void> updateBillStatusToPaid(int idHoaDon, String phuongThuc) async {
    try {
      final response = await dio.put(
        '/bill/updateDetailBillPayment',
        data: {'id_hoadon': idHoaDon, 'phuong_thuc_thanh_toan': phuongThuc},
      );

      print('Update Status Response: ${response.data}');

      // --- SỬA LỖI Ở ĐÂY ---
      // 1. Kiểm tra xem response.data có phải là Map không
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data; // Ép kiểu an toàn

        if (response.statusCode == 200 && data['success'] == true) {
          // Thành công
          return;
        } else {
          // Lấy message lỗi từ server nếu có
          final message = data['message'] ?? 'Lỗi cập nhật trạng thái';
          throw Exception(message);
        }
      } else {
        // Nếu response.data KHÔNG phải là Map (ví dụ: là List hoặc String)
        throw Exception('Server trả về định dạng dữ liệu không mong đợi.');
      }
    } on DioException catch (e) {
      print('DioError updateBillStatusToPaid: $e');

      // --- SỬA LỖI Ở ĐÂY (CHO DIOERROR) ---
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> errorData = e.response!.data;
        if (errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Lỗi kết nối: Không thể thanh toán hóa đơn.');
    } catch (e) {
      // Bắt các lỗi khác
      print('Error updateBillStatusToPaid: $e');
      throw Exception(e.toString()); // Ném lại lỗi đã được xử lý
    }
  }

  /// Hoàn tác hóa đơn về 'Chưa tạo hợp đồng'
  Future<void> revertBillStatus(int idHoaDon) async {
    try {
      // Dùng PUT (như server)
      final response = await dio.put(
        '/bill/revertBillStatus', // Endpoint mới
        data: {
          'id_hoadon': idHoaDon, // Chỉ cần gửi ID
        },
      );

      print('Revert Status Response: ${response.data}');

      // Xử lý response (tương tự hàm trên)
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> data = response.data;

        if (response.statusCode == 200 && data['success'] == true) {
          // Thành công
          return;
        } else {
          // Lỗi từ server (vd: success: false)
          final message = data['message'] ?? 'Lỗi hoàn tác hóa đơn';
          throw Exception(message);
        }
      } else {
        // Server trả về không phải JSON Map
        throw Exception('Server trả về định dạng dữ liệu không mong đợi.');
      }
    } on DioException catch (e) {
      // Lỗi Dio (404, 500, timeout)
      print('DioError revertBillStatus: $e');
      if (e.response?.data != null &&
          e.response!.data is Map<String, dynamic>) {
        final Map<String, dynamic> errorData = e.response!.data;
        if (errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Lỗi kết nối: Không thể hoàn tác hóa đơn.');
    } catch (e) {
      // Các lỗi khác
      print('Error revertBillStatus: $e');
      throw Exception(e.toString());
    }
  }
}
