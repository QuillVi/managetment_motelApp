import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/home_repository/lessee_repository/list_lessee_repository.dart';
import 'package:motelapp/data/repositories/room_repository/add_tanent_room_repository.dart';
import 'package:motelapp/logic/cubits/home/tanent_home/lessee_state.dart';

class LesseeCubit extends Cubit<LesseeState> {
  final ListLesseeRepository listTanentRepository;
  final AddTanentRoomRepository addTanentRoomRepository;
  LesseeCubit({
    required this.listTanentRepository,
    required this.addTanentRoomRepository,
  }) : super(const LesseeState());

  Future<void> loadTanents() async {
    emit(state.copyWith(status: LesseeStatus.loading));
    try {
      final tanents = await listTanentRepository.fetchTenants();
      emit(state.copyWith(status: LesseeStatus.loaded, listLessee: tanents));
    } catch (e) {
      emit(
        state.copyWith(status: LesseeStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> addTanentRoomFunctionHome(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: LesseeStatus.submitting));

    try {
      final response = await addTanentRoomRepository.addTanentRoomFunctionHome(
        payload,
      );
      emit(
        state.copyWith(
          status: LesseeStatus.addSuccess,
          payload: response,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: LesseeStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
