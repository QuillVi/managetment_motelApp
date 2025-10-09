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
}
