import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/room_repository/detail_room_repository.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/detail_room_state.dart';

class DetailRoomCubit extends Cubit<DetailRoomState> {
  final DetailRoomRepository detailRoomRepository;

  DetailRoomCubit({required this.detailRoomRepository})
    : super(const DetailRoomState());

  Future<void> loadRoomDetail(int roomId) async {
    emit(state.copyWith(status: DetailRoomStatus.loading));
    try {
      final roomDetail = await detailRoomRepository.fetchRoomDetail(roomId);
      emit(
        state.copyWith(
          status: DetailRoomStatus.success,
          data: roomDetail,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: DetailRoomStatus.failure, error: e.toString()),
      );
    }
  }
}
