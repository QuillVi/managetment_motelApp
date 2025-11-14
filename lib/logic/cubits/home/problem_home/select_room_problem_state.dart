import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/room_model.dart';

enum SelectRoomProblemStatus { initial, loading, loaded, error }

class SelectRoomProblemState extends Equatable {
  final SelectRoomProblemStatus status;
  final List<ListRoomProblemModel>? selectRoomProblem;
  final List<SelectRoomManagetModel>? selectRoomManaget;

  final String? errorMessage;

  const SelectRoomProblemState({
    this.status = SelectRoomProblemStatus.initial,
    this.selectRoomProblem,
    this.selectRoomManaget,
    this.errorMessage,
  });

  SelectRoomProblemState copyWith({
    SelectRoomProblemStatus? status,
    List<ListRoomProblemModel>? selectRoomProblem,
    List<SelectRoomManagetModel>? selectRoomManaget,
    String? errorMessage,
  }) {
    return SelectRoomProblemState(
      status: status ?? this.status,
      selectRoomProblem: selectRoomProblem ?? this.selectRoomProblem,
      selectRoomManaget: selectRoomManaget ?? this.selectRoomManaget,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    selectRoomProblem,
    selectRoomManaget,
  ];
}
