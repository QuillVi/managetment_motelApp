import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/lessee_model.dart';

enum LesseeStatus { initial, loading, loaded, error }

class LesseeState extends Equatable {
  final LesseeStatus status;
  final String? errorMessage;
  final List<LesseeModel>? listLessee;

  const LesseeState({
    this.status = LesseeStatus.initial,
    this.errorMessage,
    this.listLessee,
  });

  LesseeState copyWith({
    LesseeStatus? status,
    List<LesseeModel>? listLessee,
    String? errorMessage,
  }) {
    return LesseeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      listLessee: listLessee ?? this.listLessee,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, listLessee];
}
