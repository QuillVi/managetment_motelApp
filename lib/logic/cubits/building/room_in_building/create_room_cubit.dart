import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:motelapp/data/repositories/room_repository/create_room_repository.dart';
import 'package:motelapp/logic/cubits/building/room_in_building/create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final CreateRoomRepository createRoomRepository;

  CreateRoomCubit({required this.createRoomRepository})
    : super(const CreateRoomState());

  Future<void> createRoom(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: CreateRoomStatus.loading));

    try {
      final response = await createRoomRepository.createRoom(payload);
      emit(
        state.copyWith(
          status: CreateRoomStatus.success,
          payload: response,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: CreateRoomStatus.error, error: e.toString()));
    }
  }
}
