import 'package:equatable/equatable.dart';

enum AddTanentRoomStatus { initial, loading, success, error }

class AddTanentRoomState extends Equatable {
  final AddTanentRoomStatus status;
  final Map<String, dynamic>? payload;
  final String? error;

  const AddTanentRoomState({
    this.status = AddTanentRoomStatus.initial,
    this.error,
    this.payload,
  });

  AddTanentRoomState copyWith({
    AddTanentRoomStatus? status,
    Map<String, dynamic>? payload,
    String? error,
  }) {
    return AddTanentRoomState(
      status: status ?? this.status,
      error: error ?? this.error,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [status, error, payload];
}
