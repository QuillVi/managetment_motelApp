import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/cost_model.dart';

enum CostStatus { initial, loading, loaded, error }

class CostState extends Equatable {
  final CostStatus status;
  final List<CostModel>? costModel;
  final CostDetailModel? costDetailModel;
  final String? errorMessage;

  const CostState({
    this.status = CostStatus.initial,
    this.costModel,
    this.costDetailModel,
    this.errorMessage,
  });

  CostState copyWith({
    CostStatus? status,
    List<CostModel>? costModel,
    CostDetailModel? costDetailModel,
    String? errorMessage,
  }) {
    return CostState(
      status: status ?? this.status,
      costModel: costModel ?? this.costModel,
      costDetailModel: costDetailModel ?? this.costDetailModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, costModel, costDetailModel];
}
