import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/user_model.dart';

enum DetailTanentStatus { initial, loading, loaded, error }

class DetailTanentState extends Equatable {
  final DetailTanentStatus status;
  final String? errorMessage;
  final UserModel? detailTanent;

  const DetailTanentState({
    this.status = DetailTanentStatus.initial,
    this.errorMessage,
    this.detailTanent,
  });

  DetailTanentState copyWith({
    DetailTanentStatus? status,
    String? errorMessage,
    UserModel? detailTanent,
  }) {
    return DetailTanentState(
      status: status ?? this.status,
      detailTanent: detailTanent ?? this.detailTanent,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detailTanent, errorMessage];
}
