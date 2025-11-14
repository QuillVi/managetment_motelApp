import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/problem_model.dart';

enum DetailProblemStatus { initial, loading, loaded, error }

class DetailProblemState extends Equatable {
  final DetailProblemStatus status;
  final DetailProblemModel? detailProblem;
  final String? errorMessage;

  DetailProblemState({
    this.status = DetailProblemStatus.initial,
    this.detailProblem,
    this.errorMessage,
  });

  DetailProblemState copyWith({
    DetailProblemStatus? status,
    DetailProblemModel? detailProblem,
    String? errorMessage,
  }) {
    return DetailProblemState(
      status: status ?? this.status,
      detailProblem: detailProblem ?? this.detailProblem,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detailProblem, errorMessage];
}
