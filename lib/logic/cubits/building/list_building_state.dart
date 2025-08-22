import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/building_model.dart';

enum ListBuildingStatus { initial, loading, loaded, error }

class ListBuildingState extends Equatable {
  final ListBuildingStatus status;
  final List<BuildingModel>? data;

  final String? error;

  const ListBuildingState({
    this.status = ListBuildingStatus.initial,
    this.data,
    this.error,
  });

  ListBuildingState copyWith({
    ListBuildingStatus? status,
    List<BuildingModel>? data,
    String? error,
  }) {
    return ListBuildingState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}
