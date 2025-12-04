import 'package:dio/dio.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/models/user_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListContractRepository {
  final Dio dio = DioClient().dio;

  Future<List<ListContractModel>> fetchListContract() async {
    final response = await dio.get('/contract/getListContract');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => ListContractModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách hợp đồng');
    }
  }

  Future<DetailContractModel> getDetailContract(int idHopDong) async {
    try {
      // Giả sử endpoint của bạn là /contract/getDetailContract/18
      // Nếu endpoint của bạn dùng query params (?id=18) thì sửa lại thành:
      // await dio.get('/contract/getDetailContract', queryParameters: {'id_hopdong': idHopDong});
      final response = await dio.get('/contract/getDetailContract/$idHopDong');

      print('Response Detail Contract: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Map dữ liệu vào DetailContractModel (đã bao gồm list TenantModel bên trong)
        return DetailContractModel.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Không thể lấy chi tiết hợp đồng',
        );
      }
    } on DioException catch (e) {
      print("❌ Lỗi API Detail: ${e.response?.statusCode} - ${e.message}");
      throw Exception("Lỗi kết nối khi lấy chi tiết hợp đồng");
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      throw Exception("Lỗi không xác định: $e");
    }
  }

  Future<List<SelectTanentContractModel>>
  fetchListUserContractSelected() async {
    final response = await dio.get('/user/getListUserSelected');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => SelectTanentContractModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách người đại diện');
    }
  }

  Future<Map<String, dynamic>> createContract(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post(
        '/contract/createContract',
        data: payload,
      );

      final data = response.data;

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          print("✅ Tạo hợp đồng thành công: $data");
          return data;
        } else {
          print("⚠️ API trả về success=false: $data");
          throw Exception("API báo lỗi: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        print("⚠️ API trả về statusCode ${response.statusCode}: $data");
        throw Exception("Không thể tạo hợp đồngụ");
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

  Future<void> deleteContract(int idHopDong) async {
    try {
      // Gọi API xóa theo đúng endpoint bạn đã test
      final response = await dio.delete('/contract/deleteContract/$idHopDong');

      // Kiểm tra thành công
      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Xóa hợp đồng thành công");
        return; // Thành công thì không cần trả về gì, chỉ cần không throw lỗi
      } else {
        // Trường hợp API trả về lỗi logic (ví dụ: đã có hóa đơn thanh toán)
        throw Exception(response.data['message'] ?? 'Lỗi khi xóa hợp đồng');
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ Dio (404, 500...)
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "Lỗi server");
      }
      throw Exception("Lỗi kết nối mạng");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> liquidateContract(int idHopDong) async {
    try {
      // Gọi API PUT mà bạn vừa test xong
      final response = await dio.put('/contract/liquidateContract/$idHopDong');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Thanh lý thành công");
        return;
      } else {
        throw Exception(
          response.data['message'] ?? 'Lỗi khi thanh lý hợp đồng',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "Lỗi server");
      }
      throw Exception("Lỗi kết nối mạng: ${e.message}");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateContract(
    int idHopDong,
    Map<String, dynamic> payload,
  ) async {
    try {
      // Gọi API update theo endpoint bạn đã cấu hình ở Backend
      final response = await dio.put(
        '/contract/updateContract/$idHopDong',
        data: payload,
      );

      // Kiểm tra phản hồi
      if (response.statusCode == 200 && response.data['success'] == true) {
        print("✅ Cập nhật hợp đồng thành công: ${response.data}");
        return;
      } else {
        throw Exception(
          response.data['message'] ?? 'Lỗi khi cập nhật hợp đồng',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("❌ Lỗi API Update: ${e.response?.data}");
        throw Exception(e.response?.data['message'] ?? "Lỗi server");
      }
      throw Exception("Lỗi kết nối mạng: ${e.message}");
    } catch (e) {
      print("❌ Lỗi không xác định: $e");
      throw Exception(e.toString());
    }
  }
}
