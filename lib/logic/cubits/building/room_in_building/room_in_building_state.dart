import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/room_model.dart';

enum RoomInBuildingStatus { initial, loading, loaded, error }

class RoomInBuildingState extends Equatable {
  final RoomInBuildingStatus status;
  final List<RoomModel>? data;

  final String? error;

  const RoomInBuildingState({
    this.status = RoomInBuildingStatus.initial,
    this.data,
    this.error,
  });

  RoomInBuildingState copyWith({
    RoomInBuildingStatus? status,
    List<RoomModel>? data,
    String? error,
  }) {
    return RoomInBuildingState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
