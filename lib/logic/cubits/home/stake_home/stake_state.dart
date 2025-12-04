import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/stake_model.dart';

enum StakeStatus {
  initial,
  loading,
  loaded,
  error,
  updateSuccess,
  deleteSuccess,
}

class StakeState extends Equatable {
  final StakeStatus status;
  final List<StakeModel>? dataStake;
  final List<ContentStakeModel>? dataContentStake;
  final DetailStakeModel? detailStake;
  final SelectRoomStakeModel? selectRoomStake;

  final String? error;
  final String? message;

  const StakeState({
    this.status = StakeStatus.initial,
    this.dataStake,
    this.dataContentStake,
    this.detailStake,
    this.selectRoomStake,
    this.error,
    this.message,
  });

  StakeState copyWith({
    StakeStatus? status,
    List<StakeModel>? dataStake,
    List<ContentStakeModel>? dataContentStake,
    DetailStakeModel? detailStake,
    SelectRoomStakeModel? selectRoomStake,
    String? error,
    String? message,
  }) {
    return StakeState(
      status: status ?? this.status,
      dataStake: dataStake ?? this.dataStake,
      dataContentStake: dataContentStake ?? this.dataContentStake,
      detailStake: detailStake ?? this.detailStake,
      selectRoomStake: selectRoomStake ?? this.selectRoomStake,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    dataStake,
    dataContentStake,
    detailStake,
    selectRoomStake,
    error,
    message,
  ];
}
