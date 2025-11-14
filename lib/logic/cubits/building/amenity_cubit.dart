import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/building_repository/amenity_repository.dart';
import 'package:motelapp/logic/cubits/building/amenity_state.dart';

class AmenityCubit extends Cubit<AmenityState> {
  final AmenityRepository amenityRepository;

  AmenityCubit({required this.amenityRepository}) : super(const AmenityState());

  Future<void> loadAmenities() async {
    // Ngăn chặn việc tải lại nếu đã tải thành công và không cần refresh
    if (state.status == AmenityStatus.loading) return;

    emit(state.copyWith(status: AmenityStatus.loading, error: null));

    try {
      final uniqueAmenities = await amenityRepository.fetchUniqueAmenities();

      emit(
        state.copyWith(
          status: AmenityStatus.success,
          amenities: uniqueAmenities,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AmenityStatus.failure,
          error: e.toString(),
          amenities: [], // Xóa dữ liệu cũ nếu lỗi
        ),
      );
    }
  }

  Future<void> loadAmenitiesByToaNha(int toaNhaId) async {
    // Ngăn chặn việc tải lại nếu đã tải thành công và không cần refresh
    if (state.status == AmenityStatus.loading) return;

    emit(state.copyWith(status: AmenityStatus.loading, error: null));

    try {
      final uniqueAmenities = await amenityRepository
          .fetchUniqueAmenitiesByToaNha(toaNhaId);

      emit(
        state.copyWith(
          status: AmenityStatus.success,
          amenities: uniqueAmenities,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AmenityStatus.failure,
          error: e.toString(),
          amenities: [], // Xóa dữ liệu cũ nếu lỗi
        ),
      );
    }
  }
}
