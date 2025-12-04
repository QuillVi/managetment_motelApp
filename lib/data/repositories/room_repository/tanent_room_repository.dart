import 'package:dio/dio.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/models/tanent_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class TanentRoomRepository {
  final Dio dio = DioClient().dio;

  Future<List<TenantModel>> fetchTenantsByRoom(int roomId) async {
    final response = await dio.get('/room/getTanentsByRoom/$roomId');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print("Raw API data 1: ${response.data}");

      final List<dynamic> data = response.data['data'];
      return data.map((e) => TenantModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy người thuê của phòng');
    }
  }

  Future<List<NameRoomBuildingModel>> fetchNameRoomBuilding(int roomId) async {
    final response = await dio.get('/room/getRoomNameAndNameBuilding/$roomId');

    if (response.statusCode == 200 && response.data['success'] == true) {
      print("Raw API data: ${response.data}");

      final List<dynamic> data = response.data['data'];
      return data.map((e) => NameRoomBuildingModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy tên phòng và tên tòa nhà');
    }
  }
}
