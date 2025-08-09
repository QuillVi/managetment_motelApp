import 'package:dio/dio.dart';
import 'package:motelapp/data/models/building_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListBuildingRepository {
  final Dio dio = DioClient().dio;

  Future<List<BuildingModel>> fetchBuildings() async {
    final response = await dio.get('/building/getlistBuildings');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => BuildingModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách tòa nhà');
    }
  }
}
