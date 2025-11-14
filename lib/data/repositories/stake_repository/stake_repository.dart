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

  Future<List<ContentStakeModel>> fetchContentStakeCard() async {
    try {
      final response = await dio.get('/stake/getDepositCard');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => ContentStakeModel.fromMap(e)).toList();
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
}
