import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motelapp/data/repositories/problem_repository/create_problem_repository.dart';
import 'package:motelapp/logic/cubits/home/problem_home/create_problem_state.dart';

class CreateProblemCubit extends Cubit<CreateProblemState> {
  final CreateProblemRepository createProblemRepository;
  CreateProblemCubit({required this.createProblemRepository})
    : super(const CreateProblemState());

  Future<void> createProblem(Map<String, dynamic> payload) async {
    emit(state.copyWith(status: CreateProblemStatus.loading));

    try {
      final response = await createProblemRepository.createProblem(payload);
      emit(
        state.copyWith(
          status: CreateProblemStatus.success,
          payload: response,
          error: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CreateProblemStatus.error, error: e.toString()),
      );
    }
  }
}
