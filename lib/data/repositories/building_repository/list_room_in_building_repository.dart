import 'package:dio/dio.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/repositories/auth_repository.dart';
import 'package:motelapp/data/services/dio_client.dart';

class ListRoomInBuildingRepository {
  final Dio _dio = DioClient().dio;
  final AuthRepository _authRepository = AuthRepository();

  Future<List<RoomModel>> fetchRoomsInBuilding(int buildingId) async {
    final token = await _authRepository.getToken();

    if (token == null) {
      throw Exception(
        'Authorization Error: Token is not available. Please log in again.',
      );
    }

    final String endpoint = '/room/getRoomsByBuilding/$buildingId';

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? <dynamic>[];
        return List<RoomModel>.from(data.map((e) => RoomModel.fromMap(e)));
      } else if (response.data is Map && response.data['message'] != null) {
        // Business logic error returned from backend
        throw Exception(response.data['message']);
      } else {
        throw Exception(
          'Failed to load rooms. Status Code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network/Server Error';

      if (e.response != null) {
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          errorMessage =
              'Authentication/Authorization failed. ${e.response?.data?['message'] ?? ''}';
        } else {
          errorMessage =
              'Server responded with status ${e.response?.statusCode}';
        }
      } else {
        errorMessage = 'Connection Error: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}
