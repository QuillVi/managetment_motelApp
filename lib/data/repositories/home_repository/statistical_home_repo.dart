import 'package:dio/dio.dart';
import 'package:motelapp/data/models/statistical_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class StatisticalHomeRepository {
  final Dio dio = DioClient().dio;


  Future<StatisticalModel> fetchStatistics() async {
  final response = await dio.get('/statistical/statistics');

  if (response.statusCode == 200 && response.data['success'] == true) {
    return StatisticalModel.fromMap(response.data['data']);
  } else {
    throw Exception('Không thể lấy thống kê phòng');
  }
}
}