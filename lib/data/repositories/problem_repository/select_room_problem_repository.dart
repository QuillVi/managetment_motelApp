import 'package:dio/dio.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class SelectRoomProblemRepository {
  final Dio dio = DioClient().dio;

  Future<List<ListRoomProblemModel>> fetchListRoomProblem() async {
    final response = await dio.get('/room/getListRoomSelectByUser');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => ListRoomProblemModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách phòng');
    }
  }

  Future<List<SelectRoomManagetModel>> fetchSelectRoomManaget(
    int idNguoiThue,
  ) async {
    final response = await dio.get(
      '/room/getListRoomSelectManaget/$idNguoiThue',
    );
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => SelectRoomManagetModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách phòng');
    }
  }
}
