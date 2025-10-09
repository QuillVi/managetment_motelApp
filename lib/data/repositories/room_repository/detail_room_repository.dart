import 'package:dio/dio.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class DetailRoomRepository {
  final Dio dio = DioClient().dio;

  Future<RoomModel> fetchRoomDetail(int roomId) async {
    final response = await dio.get('/room/getDetailRoom/$roomId');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      print("data phong $data");

      return RoomModel.fromMap(data);
    } else {
      throw Exception('Không thể lấy chi tiết phòng');
    }
  }
}
