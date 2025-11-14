import 'package:dio/dio.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListContractRepository {
  final Dio dio = DioClient().dio;

  Future<List<ListContractModel>> fetchListContract() async {
    final response = await dio.get('/contract/getListContract');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => ListContractModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách hợp đồng');
    }
  }
}
