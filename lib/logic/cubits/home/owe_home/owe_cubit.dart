import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/owe_repository/owe_repository.dart';
import 'package:motelapp/logic/cubits/home/owe_home/owe_state.dart';

class OweCubit extends Cubit<OweState> {
  final OweRepository oweRepository;

  OweCubit({required this.oweRepository}) : super(const OweState());

  // Trong OweCubit.loadOweCollect
  Future<void> loadOweCollect() async {
    // ⭐️ Bỏ điều kiện chặn ở đây
    emit(
      state.copyWith(collectStatus: OweStatus.loading, error: null),
    ); // Đặt trạng thái loading cụ thể

    try {
      final debtCollect = await oweRepository.fetchCollectDebts();
      emit(
        state.copyWith(
          collectStatus: OweStatus.loaded,
          collectDebts: debtCollect,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(collectStatus: OweStatus.error, error: e.toString()));
    }
  }

  // Trong OweCubit.loadOweDoned
  Future<void> loadOweDoned() async {
    // ⭐️ Bỏ điều kiện chặn ở đây
    emit(
      state.copyWith(doneStatus: OweStatus.loading, error: null),
    ); // Đặt trạng thái loading cụ thể

    try {
      final debtDoned = await oweRepository.fetchDoneDebts();
      emit(
        state.copyWith(
          doneStatus: OweStatus.loaded,
          doneDebts: debtDoned,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(doneStatus: OweStatus.error, error: e.toString()));
    }
  }
}
