import 'package:equatable/equatable.dart';

enum CreateProblemStatus { initial, loading, success, error }

class CreateProblemState extends Equatable {
  final CreateProblemStatus status;
  final Map<String, dynamic>? payload;
  final String? error;

  const CreateProblemState({
    this.status = CreateProblemStatus.initial,
    this.error,
    this.payload,
  });

  CreateProblemState copyWith({
    CreateProblemStatus? status,
    Map<String, dynamic>? payload,
    String? error,
  }) {
    return CreateProblemState(
      status: status ?? this.status,
      error: error ?? this.error,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [status, error, payload];
}
