import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/problem_repository/detail_problem_repository.dart';
import 'package:motelapp/logic/cubits/home/problem_home/detail_problem_state.dart';

class DetailProblemCubit extends Cubit<DetailProblemState> {
  final DetailProblemRepository detailProblemRepository;
  DetailProblemCubit({required this.detailProblemRepository})
    : super(DetailProblemState());

  Future<void> loadDetailProblem(int problemId) async {
    emit(state.copyWith(status: DetailProblemStatus.loading));
    try {
      final detailProblem = await detailProblemRepository.fetchDetailProblem(
        problemId,
      );
      emit(
        state.copyWith(
          status: DetailProblemStatus.loaded,
          detailProblem: detailProblem,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: DetailProblemStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> markAsComplete(int problemId) async {
    // 1. Chuyển trạng thái sang completing (để hiện loading ở nút bấm)
    emit(state.copyWith(status: DetailProblemStatus.completing));

    try {
      // 2. Gọi repo
      final success = await detailProblemRepository.completeProblem(problemId);

      if (success) {
        // 3a. Nếu thành công -> Báo Success
        emit(state.copyWith(status: DetailProblemStatus.completeSuccess));

        // 4. Load lại data mới nhất để UI cập nhật chữ "Đang yêu cầu" -> "Hoàn thành"
        await loadDetailProblem(problemId);
      }
    } catch (e) {
      // 3b. Nếu lỗi -> Báo Failure
      emit(
        state.copyWith(
          status: DetailProblemStatus.completeFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
