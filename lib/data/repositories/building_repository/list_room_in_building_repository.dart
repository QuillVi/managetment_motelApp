import 'package:dio/dio.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListRoomInBuildingRepository {
  final Dio dio = DioClient().dio;

  Future<List<RoomModel>> fetchRoomsInBuilding(int buildingId) async {
    final response = await dio.get('/room/getRoomsByBuilding/$buildingId');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => RoomModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách phòng trong tòa nhà');
    }
  }
}
