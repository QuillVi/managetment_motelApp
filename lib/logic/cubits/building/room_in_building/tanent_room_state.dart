import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/room_model.dart';
import 'package:motelapp/data/models/tanent_model.dart';

enum TanentRoomStatus { initial, loading, loaded, error }

class TanentRoomState extends Equatable {
  final TanentRoomStatus status;
  final String? errorMessage;
  final List<TenantModel>? tanent;
  final List<NameRoomBuildingModel>? nameRoomBuilding;

  const TanentRoomState({
    this.status = TanentRoomStatus.initial,
    this.errorMessage,
    this.tanent,
    this.nameRoomBuilding,
  });

  TanentRoomState copyWith({
    TanentRoomStatus? status,
    String? errorMessage,
    List<TenantModel>? tanent,
    List<NameRoomBuildingModel>? nameRoomBuilding,
  }) {
    return TanentRoomState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tanent: tanent ?? this.tanent,
      nameRoomBuilding: nameRoomBuilding ?? this.nameRoomBuilding,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, tanent, nameRoomBuilding];
}
