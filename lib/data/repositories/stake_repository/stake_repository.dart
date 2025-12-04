import 'package:dio/dio.dart';
import 'package:motelapp/data/models/stake_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class StakeRepository {
  final Dio dio = DioClient().dio;

  Future<List<StakeModel>> fetchStake() async {
    try {
      final response = await dio.get('/stake/getDepositStatus');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => StakeModel.fromMap(e)).toList();
      } else {
        throw Exception('Không thể lấy dữ liệu thống kê');
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Future<List<ContentStakeModel>> fetchContentStakeCard() async {
  //   try {
  //     final response = await dio.get('/stake/getDepositCard');

  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       final List<dynamic> data = response.data['data'];
  //       return data.map((e) => ContentStakeModel.fromMap(e)).toList();
  //     } else {
  //       throw Exception('Không thể lấy dữ liệu thống kê');
  //     }
  //   } on DioException catch (e) {
  //     final statusCode = e.response?.statusCode;
  //     throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }
  // }

  Future<List<ContentStakeModel>> fetchContentStakeCard() async {
    print("🚀 [REPO] 1. Bắt đầu fetchContentStakeCard");
    try {
      print("🚀 [REPO] 2. Chuẩn bị gọi Dio GET: /stake/getDepositCard");

      // Gọi API
      final response = await dio.get('/stake/getDepositCard');

      print("🚀 [REPO] 3. Dio đã phản hồi! Status: ${response.statusCode}");
      // In thử cấu trúc data trả về để xem có key 'data' không
      print("🚀 [REPO] 4. Data raw: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        print("🚀 [REPO] 5. API báo Success. Đang parse dữ liệu...");

        final List<dynamic> data = response.data['data'];

        // Map dữ liệu
        final list = data.map((e) => ContentStakeModel.fromMap(e)).toList();

        print("🚀 [REPO] 6. Parse xong ${list.length} item. Return kết quả.");
        return list;
      } else {
        print("🚀 [REPO] X. Lỗi Logic: Status khác 200 hoặc success false");
        throw Exception('Không thể lấy dữ liệu thống kê');
      }
    } on DioException catch (e) {
      print(
        "🚀 [REPO] X. DioException: ${e.message}",
      ); // Lỗi mạng, timeout, 404...
      final statusCode = e.response?.statusCode;
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
    } catch (e) {
      print("🚀 [REPO] X. Lỗi Khác (Parse lỗi?): $e");
      throw Exception(e.toString());
    }
  }

  Future<DetailStakeModel> fetchDetailStake(int idHopDong) async {
    try {
      // Gọi đúng endpoint đã định nghĩa bên Node.js: /detail/:id
      final response = await dio.get('/stake/getDepositDetail/$idHopDong');
      print("API Response Type: ${response.data.runtimeType}"); // Kiểm tra kiểu
      print("API Data: ${response.data}"); // Kiểm tra dữ liệu

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Dữ liệu trả về là 1 Object, không phải List
        final dynamic data = response.data['data'];
        return DetailStakeModel.fromMap(data);
      } else {
        throw Exception('Không thể lấy chi tiết cọc');
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ server trả về (ví dụ 404 không tìm thấy, 400 thiếu id)
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Hàm hủy cọc (Gọi API PUT)
  Future<String> cancelStake(int idHopDong) async {
    try {
      // Lưu ý: Sử dụng dio.put vì API bên Node.js là router.put
      final response = await dio.put('/stake/cancelStake/$idHopDong');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Trả về message từ server (VD: "Đã hủy cọc và cập nhật...") để hiển thị thông báo
        return response.data['message'];
      } else {
        throw Exception(response.data['message'] ?? 'Không thể hủy cọc');
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ server (404, 400, 500...)
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Tạo cọc mới
  Future<String> createStake(Map<String, dynamic> payload) async {
    try {
      // POST request gửi cục payload lên
      final response = await dio.post('/stake/createStake', data: payload);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['message'] ?? "Tạo cọc thành công";
      } else {
        throw Exception(response.data['message'] ?? 'Thao tác thất bại');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi kết nối');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<SelectRoomStakeModel> fetchRoomsByDepositStatus() async {
    try {
      final response = await dio.get('/stake/getRoomsByDepositStatus');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Parse cục 'data' (chứa da_co_coc và chua_co_coc) vào Model
        return SelectRoomStakeModel.fromMap(response.data['data']);
      } else {
        throw Exception('Không thể lấy danh sách phòng');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi mạng hoặc server');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> updateStake(int idCoc, Map<String, dynamic> payload) async {
    try {
      // Gọi API PUT: /stake/update/{id}
      final response = await dio.put(
        '/stake/updateStake/$idCoc',
        data: payload,
      );

      print("Update Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true; // Cập nhật thành công
      } else {
        throw Exception(response.data['message'] ?? 'Cập nhật thất bại');
      }
    } on DioException catch (e) {
      // Xử lý lỗi từ server (400, 404, 500...)
      final errorMsg = e.response?.data['message'] ?? 'Lỗi kết nối server';
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Hàm xóa cọc
  Future<bool> deleteStake(int idCoc) async {
    try {
      // Gọi API: DELETE /api/stakes/{id}
      final response = await dio.delete('/stake/deleteStake/$idCoc');

      // Kiểm tra status code hoặc body trả về
      // Server trả về: { success: true, message: "..." }
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      // Log lỗi nếu cần
      print("Error deleting stake: $e");
      throw e; // Ném lỗi để Cubit bắt
    }
  }
}
