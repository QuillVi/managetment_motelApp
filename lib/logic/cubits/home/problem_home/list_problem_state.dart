import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/problem_model.dart';

enum ListProblemStatus { initial, loading, loaded, error }

class ListProblemState extends Equatable {
  final ListProblemStatus status;
  final List<ProblemModelRequesting>? problemsRequesting;
  final List<ProblemModelDoned>? problemsDoned;
  final String? errorMessage;

  const ListProblemState({
    this.status = ListProblemStatus.initial,
    this.problemsRequesting,
    this.problemsDoned,
    this.errorMessage,
  });

  ListProblemState copyWith({
    ListProblemStatus? status,
    List<ProblemModelRequesting>? problemsRequesting,
    List<ProblemModelDoned>? problemsDoned,
    String? errorMessage,
  }) {
    return ListProblemState(
      status: status ?? this.status,
      problemsRequesting: problemsRequesting ?? this.problemsRequesting,
      problemsDoned: problemsDoned ?? this.problemsDoned,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    problemsRequesting,
    problemsDoned,
  ];
}
