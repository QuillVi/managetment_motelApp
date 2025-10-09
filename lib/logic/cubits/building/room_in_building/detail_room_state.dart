import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/room_model.dart';

enum DetailRoomStatus { initial, loading, success, failure }

class DetailRoomState extends Equatable {
  final DetailRoomStatus status;
  final RoomModel? data;
  final String? error;

  const DetailRoomState({
    this.status = DetailRoomStatus.initial,
    this.data,
    this.error,
  });

  DetailRoomState copyWith({
    DetailRoomStatus? status,
    RoomModel? data,
    String? error,
  }) {
    return DetailRoomState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
