import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/building_repository/list_building_repo.dart';
import 'package:motelapp/logic/cubits/building/list_building_state.dart';


class ListBuildingCubit extends Cubit<ListBuildingState> {
  final ListBuildingRepository listBuildingRepository;

  ListBuildingCubit({required this.listBuildingRepository})
      : super(const ListBuildingState());

  Future<void> loadBuildings() async {
    emit(state.copyWith(status: ListBuildingStatus.loading));

    try {
      final buildings = await listBuildingRepository.fetchBuildings();
      emit(state.copyWith(
        status: ListBuildingStatus.loaded,
        data: buildings,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ListBuildingStatus.error,
        error: e.toString(),
      ));
    }
  }
}
