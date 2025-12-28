import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/User_model/contract_user_model.dart';

enum ContractUserStatus { initial, loading, loaded, error }

class ContractUserState extends Equatable {
  final ContractUserStatus status;
  // Vì API này trả về chi tiết 1 hợp đồng (Object), không phải List
  final DetailContractUserModel? detailContractUser;
  final String? errorMessage;

  const ContractUserState({
    this.status = ContractUserStatus.initial,
    this.detailContractUser,
    this.errorMessage,
  });

  ContractUserState copyWith({
    ContractUserStatus? status,
    DetailContractUserModel? detailContractUser,
    String? errorMessage,
  }) {
    return ContractUserState(
      status: status ?? this.status,
      detailContractUser: detailContractUser ?? this.detailContractUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detailContractUser, errorMessage];
}
