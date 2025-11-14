import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/cost_repository/cost_repository.dart';
import 'package:motelapp/logic/cubits/cost/cost_state.dart';

class CostCubit extends Cubit<CostState> {
  final CostRepository costRepository;
  CostCubit({required this.costRepository}) : super(const CostState());

  Future<void> LoadListCost() async {
    emit(state.copyWith(status: CostStatus.loading));
    try {
      final listCost = await costRepository.fetchListCost();
      emit(
        state.copyWith(
          status: CostStatus.loaded,
          costModel: listCost,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CostStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadCostDetail(int idHoaDon) async {
    emit(state.copyWith(status: CostStatus.loading));
    try {
      final costDetail = await costRepository.fetchCostDetail(idHoaDon);
      emit(
        state.copyWith(
          status: CostStatus.loaded,
          costDetailModel: costDetail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CostStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
