import 'package:dio/dio.dart';
import 'package:motelapp/data/models/building_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class DetailBuildingRepository {
  final Dio dio = DioClient().dio;

  Future<BuildingModel> fetchBuildingDetail(int buildingId) async {
    final response = await dio.get('/building/getDetailBuilding/$buildingId');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      print("data toa nha $data");
      return BuildingModel.fromMap(data);
    } else {
      throw Exception('Không thể lấy chi tiết tòa nhà');
    }
  }
}
