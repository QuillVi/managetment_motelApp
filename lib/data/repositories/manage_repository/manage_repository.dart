import 'package:dio/dio.dart';
import 'package:motelapp/data/models/user_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ManageRepository {
  final Dio dio = DioClient().dio;

  Future<ManageModel> fetchManage() async {
    final response = await dio.get('/user/getManagement');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> dataList = response.data['data'];

      if (dataList.isNotEmpty) {
        final Map<String, dynamic> dataMap = dataList.first;
        return ManageModel.fromMap(dataMap);
      } else {
        throw Exception('Khong tim thay du lieu quan ly');
      }
    } else {
      throw Exception('Khong thuc hien duoc');
    }
  }
}
