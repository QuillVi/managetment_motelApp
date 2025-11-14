import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/user_model.dart';

enum ManageStatus { initial, loading, loaded, error }

class ManageState extends Equatable {
  final ManageStatus status;
  final String? error;
  final ManageModel? manage;

  const ManageState({
    this.status = ManageStatus.initial,
    this.error,
    this.manage,
  });

  ManageState copyWith({
    ManageStatus? status,
    String? error,
    ManageModel? manage,
  }) {
    return ManageState(
      status: status ?? this.status,
      error: error ?? this.error,
      manage: manage ?? this.manage,
    );
  }

  @override
  List<Object?> get props => [status, error, manage];
}
