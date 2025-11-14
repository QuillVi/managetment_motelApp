import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/stake_repository/stake_repository.dart';
import 'package:motelapp/logic/cubits/home/stake_home/stake_state.dart';

class StakeCubit extends Cubit<StakeState> {
  final StakeRepository stakeRepository;

  StakeCubit({required this.stakeRepository}) : super(const StakeState());

  Future<void> loadStake() async {
    // Chỉ thực hiện load nếu không phải đang trong trạng thái loading
    if (state.status == StakeStatus.loading) return;

    emit(
      state.copyWith(status: StakeStatus.loading, error: null),
    ); // Reset error

    try {
      final dataStake = await stakeRepository.fetchStake();
      print("Fetched data: $dataStake");

      emit(
        state.copyWith(
          status: StakeStatus.loaded,
          dataStake: dataStake,
          error: null,
        ),
      );
    } catch (e) {
      // Bắt tất cả các lỗi khác (lỗi mạng, lỗi server 500, lỗi parsing,...)
      final err = e.toString();
      emit(state.copyWith(status: StakeStatus.error, error: err));
    }
  }
}

class ContentStakeCubit extends Cubit<StakeState> {
  final StakeRepository stakeRepository;

  ContentStakeCubit({required this.stakeRepository})
    : super(const StakeState());

  Future<void> loadContentStake() async {
    // Chỉ thực hiện load nếu không phải đang trong trạng thái loading
    if (state.status == StakeStatus.loading) return;

    emit(
      state.copyWith(status: StakeStatus.loading, error: null),
    ); // Reset error

    try {
      final dataContentStake = await stakeRepository.fetchContentStakeCard();
      print("Fetched data: $dataContentStake");

      emit(
        state.copyWith(
          status: StakeStatus.loaded,
          dataContentStake: dataContentStake,
          error: null,
        ),
      );
    } catch (e) {
      // Bắt tất cả các lỗi khác (lỗi mạng, lỗi server 500, lỗi parsing,...)
      final err = e.toString();
      emit(state.copyWith(status: StakeStatus.error, error: err));
    }
  }
}
