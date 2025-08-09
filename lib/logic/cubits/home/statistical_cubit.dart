import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/home_repository/statistical_home_repo.dart';
import 'statistical_state.dart';

class StatisticalCubit extends Cubit<StatisticalState> {
  final StatisticalHomeRepository statisticalHomeRepository;

  StatisticalCubit({required this.statisticalHomeRepository})
      : super(const StatisticalState());

  Future<void> loadStatistics() async {
    emit(state.copyWith(status: StatisticalStatus.loading));

    try {
      final data = await statisticalHomeRepository.fetchStatistics();
      emit(state.copyWith(
        status: StatisticalStatus.loaded,
        data: data,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatisticalStatus.error,
        error: e.toString(),
      ));
    }
  }
}
