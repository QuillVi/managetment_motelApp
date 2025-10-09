import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/building_repository/detail_building_repository.dart';
import 'package:motelapp/logic/cubits/building/detail_building_state.dart';

class DetailBuildingCubit extends Cubit<DetailBuildingState> {
  final DetailBuildingRepository detailBuildingRepository;

  DetailBuildingCubit({required this.detailBuildingRepository})
      : super(const DetailBuildingState());

  Future<void> loadBuildingDetail(int buildingId) async {
    emit( state.copyWith(status: DetailBuildingStatus.loading));
    try {
      final buildingDetail =
          await detailBuildingRepository.fetchBuildingDetail(buildingId);
      emit(state.copyWith(
        status: DetailBuildingStatus.success,
        data: buildingDetail,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DetailBuildingStatus.failure,
        error: e.toString(),
      ));
    }
  }
}