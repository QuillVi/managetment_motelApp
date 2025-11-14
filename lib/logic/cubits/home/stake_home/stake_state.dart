import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/stake_model.dart';

enum StakeStatus { initial, loading, loaded, error }

class StakeState extends Equatable {
  final StakeStatus status;
  final List<StakeModel>? dataStake;
  final List<ContentStakeModel>? dataContentStake;

  final String? error;

  const StakeState({
    this.status = StakeStatus.initial,
    this.dataStake,
    this.dataContentStake,
    this.error,
  });

  StakeState copyWith({
    StakeStatus? status,
    List<StakeModel>? dataStake,
    List<ContentStakeModel>? dataContentStake,
    String? error,
  }) {
    return StakeState(
      status: status ?? this.status,
      dataStake: dataStake ?? this.dataStake,
      dataContentStake: dataContentStake ?? this.dataContentStake,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, dataStake, dataContentStake, error];
}
