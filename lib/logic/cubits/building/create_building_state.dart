import 'package:equatable/equatable.dart';

enum CreateBuildingStatus { initial, loading, success, error }

class CreateBuildingState extends Equatable {
  final CreateBuildingStatus status;
  final Map<String, dynamic>? payload;
  final String? error;

  const CreateBuildingState({
    this.status = CreateBuildingStatus.initial,
    this.error,
    this.payload,
  });

  CreateBuildingState copyWith({
    CreateBuildingStatus? status,
    Map<String, dynamic>? payload,
    String? error,
  }) {
    return CreateBuildingState(
      status: status ?? this.status,
      error: error ?? this.error,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [status, error, payload];
}
