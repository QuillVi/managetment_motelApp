import 'package:dio/dio.dart';
import 'package:motelapp/data/models/problem_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListProblemRequestingRepository {
  final Dio dio = DioClient().dio;

  Future<List<ProblemModelRequesting>> fetchListProblemRequesting() async {
    final response = await dio.get('/problem/getListProblemRequesting');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => ProblemModelRequesting.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách sự cố đang yêu cầu');
    }
  }
}

class ListProblemDoneRepository {
  final Dio dio = DioClient().dio;

  Future<List<ProblemModelDoned>> fetchListProblemDoned() async {
    final response = await dio.get('/problem/getListProblemDoned');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => ProblemModelDoned.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách sự cố hoàn thành');
    }
  }
}

class ListProblemByUserIdRepository {
  final Dio dio = DioClient().dio;

  Future<List<ProblemUserModel>> fetchListProblemUser() async {
    final response = await dio.get('/problem/getProblemByUserId');
    print('Response data: ${response.data}');

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'];
      return data.map((e) => ProblemUserModel.fromMap(e)).toList();
    } else {
      throw Exception('Không thể lấy danh sách sự cố hoàn thành');
    }
  }
}
