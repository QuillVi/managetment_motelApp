import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/statistical_model.dart';

enum StatisticalStatus { initial, loading, loaded, error }

class StatisticalState extends Equatable {
  final StatisticalStatus status;
  final StatisticalModel? data;
  final String? error;

  const StatisticalState({
    this.status = StatisticalStatus.initial,
    this.data,
    this.error,
  });

  StatisticalState copyWith({
    StatisticalStatus? status,
    StatisticalModel? data,
    String? error,
  }) {
    return StatisticalState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
