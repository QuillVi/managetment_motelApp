import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/contract_model.dart';

enum ListContractIsActiveStatus { initial, loading, loaded, error }

class ListContractState extends Equatable {
  final ListContractIsActiveStatus status;
  final List<ListContractModel>? listContractModel;
  final String? errorMessage;

  const ListContractState({
    this.status = ListContractIsActiveStatus.initial,
    this.listContractModel,
    this.errorMessage,
  });

  ListContractState copyWith({
    ListContractIsActiveStatus? status,
    List<ListContractModel>? listContractModel,
    String? errorMessage,
  }) {
    return ListContractState(
      status: status ?? this.status,
      listContractModel: listContractModel ?? this.listContractModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, listContractModel];
}
