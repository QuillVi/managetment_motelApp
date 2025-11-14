import 'package:dio/dio.dart';
import 'package:motelapp/data/models/user_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class DetailTanentReposittory {
  final Dio dio = DioClient().dio;

  Future<UserModel> fetchDetailTanent(int idNguoiThue) async {
    final response = await dio.get('/user/getUserById/$idNguoiThue');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      print("data nguoi thue $data");

      return UserModel.fromMap(data);
    } else {
      throw Exception('Không thể lấy chi tiết người thuê');
    }
  }
}
