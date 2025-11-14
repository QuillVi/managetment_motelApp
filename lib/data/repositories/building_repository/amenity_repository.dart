import 'package:dio/dio.dart';
import 'package:motelapp/data/models/amenity_model.dart';
import 'package:motelapp/data/services/dio_client.dart';

class AmenityRepository {
  final Dio dio = DioClient().dio;

  // Logic tách chuỗi và loại bỏ trùng lặp
  List<String> _getUniqueAmenities(List<AmenityModel> rawAmenities) {
    Set<String> uniqueServices = {};

    for (var amenity in rawAmenities) {
      // Tách chuỗi bằng dấu phẩy, làm sạch khoảng trắng
      List<String> items =
          amenity.tienIchToaNha.split(',').map((s) => s.trim()).toList();

      // Thêm vào Set để đảm bảo độc nhất
      for (String item in items) {
        if (item.isNotEmpty) {
          uniqueServices.add(item);
        }
      }
    }
    return uniqueServices.toList();
  }

  Future<List<String>> fetchUniqueAmenities() async {
    final response = await dio.get(
      '/building/getlistBuildingAmenities',
    ); // Thay thế bằng endpoint thực tế của bạn

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> rawDataList = response.data['data'];

      // 1. Map dữ liệu thô sang AmenityModel
      final List<AmenityModel> rawAmenities =
          rawDataList.map((map) => AmenityModel.fromMap(map)).toList();

      // 2. Xử lý logic tách chuỗi và loại bỏ trùng lặp
      return _getUniqueAmenities(rawAmenities);
    } else {
      throw Exception('Không thể tải danh sách tiện ích.');
    }
  }

  Future<List<String>> fetchUniqueAmenitiesByToaNha(int toaNhaId) async {
    final response = await dio.get(
      '/building/getlistBuildingAmenitiesByToaNha/$toaNhaId',
    ); // Thay thế bằng endpoint thực tế của bạn

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> rawDataList = response.data['data'];

      // 1. Map dữ liệu thô sang AmenityModel
      final List<AmenityModel> rawAmenities =
          rawDataList.map((map) => AmenityModel.fromMap(map)).toList();

      // 2. Xử lý logic tách chuỗi và loại bỏ trùng lặp
      return _getUniqueAmenities(rawAmenities);
    } else {
      throw Exception('Không thể tải danh sách tiện ích.');
    }
  }
}
