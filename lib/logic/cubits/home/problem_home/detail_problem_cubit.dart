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
}
