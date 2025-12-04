import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/lessee_model.dart';

enum LesseeStatus { initial, loading, submitting, loaded, addSuccess, error }

class LesseeState extends Equatable {
  final LesseeStatus status;
  final String? errorMessage;
  final List<LesseeModel>? listLessee;
  final Map<String, dynamic>? payload;

  const LesseeState({
    this.status = LesseeStatus.initial,
    this.errorMessage,
    this.listLessee,
    this.payload,
  });

  LesseeState copyWith({
    LesseeStatus? status,
    List<LesseeModel>? listLessee,
    Map<String, dynamic>? payload,
    String? errorMessage,
  }) {
    return LesseeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,

      listLessee: listLessee ?? this.listLessee,

      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, listLessee, payload];
}
