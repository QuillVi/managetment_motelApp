import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/tanent_model.dart';

enum TanentRoomStatus { initial, loading, loaded, error }

class TanentRoomState extends Equatable {
  final TanentRoomStatus status;
  final String? errorMessage;
  final List<TenantModel>? tanent;

  const TanentRoomState({
    this.status = TanentRoomStatus.initial,
    this.errorMessage,
    this.tanent,
  });

  TanentRoomState copyWith({
    TanentRoomStatus? status,
    String? errorMessage,
    List<TenantModel>? tanent,
  }) {
    return TanentRoomState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tanent: tanent ?? this.tanent,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, tanent];
}
