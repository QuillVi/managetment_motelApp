import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/problem_repository/list_problem_repository.dart';
import 'package:motelapp/logic/cubits/home/problem_home/list_problem_state.dart';

class ListProblemRequestingCubit extends Cubit<ListProblemState> {
  final ListProblemRequestingRepository listProblemRequestingRepository;
  ListProblemRequestingCubit({required this.listProblemRequestingRepository})
    : super(const ListProblemState());

  Future<void> loadListProblemRequesting() async {
    emit(state.copyWith(status: ListProblemStatus.loading));
    try {
      final problemsRequesting =
          await listProblemRequestingRepository.fetchListProblemRequesting();
      emit(
        state.copyWith(
          status: ListProblemStatus.loaded,
          problemsRequesting: problemsRequesting,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListProblemStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

class ListProblemDonedCubit extends Cubit<ListProblemState> {
  final ListProblemDoneRepository listProblemDoneRepository;
  ListProblemDonedCubit({required this.listProblemDoneRepository})
    : super(const ListProblemState());

  Future<void> loadListProblemDoned() async {
    emit(state.copyWith(status: ListProblemStatus.loading));
    try {
      final problemsDoned =
          await listProblemDoneRepository.fetchListProblemDoned();
      emit(
        state.copyWith(
          status: ListProblemStatus.loaded,
          problemsDoned: problemsDoned,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListProblemStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}

class ListProblemUserCubit extends Cubit<ListProblemState> {
  final ListProblemByUserIdRepository listProblemByUserIdRepository;
  ListProblemUserCubit({required this.listProblemByUserIdRepository})
    : super(const ListProblemState());

  Future<void> loadListProblemUser() async {
    emit(state.copyWith(status: ListProblemStatus.loading));
    try {
      final problemsUser =
          await listProblemByUserIdRepository.fetchListProblemUser();
      emit(
        state.copyWith(
          status: ListProblemStatus.loaded,
          problemsUser: problemsUser,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ListProblemStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
