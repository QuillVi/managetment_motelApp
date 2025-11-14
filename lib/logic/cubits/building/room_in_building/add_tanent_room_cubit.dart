import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/room_repository/add_tanent_room_repository.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/add_tanent_room_state.dart';

class AddTanentRoomCubit extends Cubit<AddTanentRoomState> {
  final AddTanentRoomRepository addTanentRoomRepository;

  AddTanentRoomCubit({required this.addTanentRoomRepository})
    : super(const AddTanentRoomState());

  Future<void> addTanentRoom(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: AddTanentRoomStatus.loading));

    try {
      final response = await addTanentRoomRepository.addTanentRoom(payload);
      emit(
        state.copyWith(
          status: AddTanentRoomStatus.success,
          payload: response,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AddTanentRoomStatus.error, error: e.toString()),
      );
    }
  }
}
