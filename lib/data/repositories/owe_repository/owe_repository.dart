import 'package:dio/dio.dart';
import 'package:motelapp/data/models/owe_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class OweRepository {
  final Dio dio = DioClient().dio;

  Future<List<OweModel>> fetchCollectDebts() async {
    // Đổi tên hàm cho rõ ràng hơn
    // Endpoint của bạn là 'getDoneDebtById', rất có thể là để lấy hóa đơn ĐÃ THANH TOÁN
    final response = await dio.get('/debt/getCollectDebtById');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      // Sửa: Đảm bảo tên phương thức parsing (fromMap) khớp với Model
      return data.map((e) => OweModel.fromMap(e)).toList();
    } else {
      // Nên trả về một thông báo lỗi cụ thể hơn
      throw Exception(
        'Lỗi ${response.statusCode}: Không thể lấy dữ liệu hóa đơn chưa thanh toán.',
      );
    }
  }

  Future<List<OweModel>> fetchDoneDebts() async {
    try {
      final response = await dio.get('/debt/getDoneDebtById');

      // Nếu đến được đây, nghĩa là API đã trả về 200/400/500 code

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        return data.map((e) => OweModel.fromMap(e)).toList();
      } else {
        // Bạn sẽ thấy lệnh này nếu API trả về 200 OK nhưng success: false
        print(
          '❌ Done Debt API Failed (success: false). Response: ${response.data}',
        );
        throw Exception(response.data['message'] ?? 'API trả về lỗi.');
      }
    } on DioException catch (e) {
      // BẮT LỖI MẠNG HOẶC LỖI HTTP KHÔNG PHẢI 200 (ví dụ: 404, 500)
      print(
        '❌ Done Debt API DioException: ${e.response?.statusCode} - ${e.message}',
      );
      rethrow; // Ném lại lỗi để Cubit bắt.
    } catch (e) {
      print('❌ Done Debt API Unknown Error: $e');
      throw Exception('Lỗi không xác định khi lấy hóa đơn đã thanh toán.');
    }
  }
}
