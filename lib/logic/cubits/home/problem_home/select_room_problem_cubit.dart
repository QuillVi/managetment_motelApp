import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/problem_repository/select_room_problem_repository.dart';
import 'package:motelapp/logic/cubits/home/problem_home/select_room_problem_state.dart';

class SelectRoomProblemCubit extends Cubit<SelectRoomProblemState> {
  final SelectRoomProblemRepository selectRoomProblemRepository;
  SelectRoomProblemCubit({required this.selectRoomProblemRepository})
    : super(const SelectRoomProblemState());

  Future<void> loadListRoomProblem() async {
    emit(state.copyWith(status: SelectRoomProblemStatus.loading));
    try {
      final selectRoomProblem =
          await selectRoomProblemRepository.fetchListRoomProblem();
      emit(
        state.copyWith(
          status: SelectRoomProblemStatus.loaded,
          selectRoomProblem: selectRoomProblem,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SelectRoomProblemStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadRoomManaget(int idNguoiThue) async {
    emit(state.copyWith(status: SelectRoomProblemStatus.loading));
    try {
      final selectRoomManaget = await selectRoomProblemRepository
          .fetchSelectRoomManaget(idNguoiThue);
      emit(
        state.copyWith(
          status: SelectRoomProblemStatus.loaded,
          selectRoomManaget: selectRoomManaget,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SelectRoomProblemStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
