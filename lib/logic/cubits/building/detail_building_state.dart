import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/building_model.dart';

enum DetailBuildingStatus { initial, loading, success, failure }

class DetailBuildingState extends Equatable {
  final DetailBuildingStatus status;
  final BuildingModel? data;
  final String? error;

  const DetailBuildingState({
    this.status = DetailBuildingStatus.initial,
    this.data,
    this.error,
  });

  DetailBuildingState copyWith({
    DetailBuildingStatus? status,
    BuildingModel? data,
    String? error,
  }) {
    return DetailBuildingState(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, data, error];
}