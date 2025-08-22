import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/building_repository/list_room_in_building_repository.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/room_in_building_state.dart';

class RoomInBuildingCubit extends Cubit<RoomInBuildingState> {
  final ListRoomInBuildingRepository listRoomInBuildingRepository;

  RoomInBuildingCubit({required this.listRoomInBuildingRepository})
    : super(const RoomInBuildingState());

  Future<void> loadRoomsInBuilding(int buildingId) async {
    emit(state.copyWith(status: RoomInBuildingStatus.loading));
    try {
      final rooms = await listRoomInBuildingRepository.fetchRoomsInBuilding(
        buildingId,
      );
      emit(
        state.copyWith(
          status: RoomInBuildingStatus.loaded,
          data: rooms,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: RoomInBuildingStatus.error, error: e.toString()),
      );
    }
  }
}
