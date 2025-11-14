import 'package:equatable/equatable.dart';

enum CreateRoomStatus { initial, loading, success, error }

class CreateRoomState extends Equatable {
  final CreateRoomStatus status;
  final Map<String, dynamic>? payload;
  final String? error;

  const CreateRoomState({
    this.status = CreateRoomStatus.initial,
    this.error,
    this.payload,
  });

  CreateRoomState copyWith({
    CreateRoomStatus? status,
    Map<String, dynamic>? payload,
    String? error,
  }) {
    return CreateRoomState(
      status: status ?? this.status,
      error: error ?? this.error,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [status, error, payload];
}
