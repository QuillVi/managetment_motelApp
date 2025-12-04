import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/contract_model.dart';
import 'package:motelapp/data/models/user_model.dart';

enum ListContractIsActiveStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  createSuccess,
  createFailure,
  deleting,
  deleteSuccess,
  deleteFailure,
  liquidating,
  liquidateSuccess,
  liquidateFailure,

  updating,
  updateSuccess,
  updateFailure,
}

class ListContractState extends Equatable {
  final ListContractIsActiveStatus status;
  final List<ListContractModel>? listContractModel;
  final List<SelectTanentContractModel>? listUserContractSelected;
  final DetailContractModel? detailContractModel;
  final Map<String, dynamic>? payload;
  final String? errorMessage;

  const ListContractState({
    this.status = ListContractIsActiveStatus.initial,
    this.listContractModel,
    this.listUserContractSelected,
    this.detailContractModel,
    this.payload,
    this.errorMessage,
  });

  ListContractState copyWith({
    ListContractIsActiveStatus? status,
    List<ListContractModel>? listContractModel,
    List<SelectTanentContractModel>? listUserContractSelected,
    DetailContractModel? detailContractModel,
    Map<String, dynamic>? payload,
    String? errorMessage,
  }) {
    return ListContractState(
      status: status ?? this.status,
      listContractModel: listContractModel ?? this.listContractModel,
      listUserContractSelected:
          listUserContractSelected ?? this.listUserContractSelected,
      detailContractModel: detailContractModel ?? this.detailContractModel,
      payload: payload ?? this.payload,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    listContractModel,
    listUserContractSelected,
    detailContractModel,
    payload,
  ];
}
