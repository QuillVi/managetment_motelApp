import 'package:dio/dio.dart';
import 'package:motelapp/data/models/lessee_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListLesseeRepository {
  final Dio dio = DioClient().dio;

  Future<List<LesseeModel>> fetchTenants() async {
    final response = await dio.get('/user/getListLessee');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => LesseeModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách người thuê');
    }
  }
}
