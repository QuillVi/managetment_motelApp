import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/User_model/bill_user_model.dart';

enum BillUserStatus { initial, loading, loaded, error }

class BillUserState extends Equatable {
  final BillUserStatus status;
  final List<BillUserModel>? billUserList; // Danh sách hóa đơn của User
  final DetailBillUserModel? detailBillUser;
  final String? errorMessage;

  const BillUserState({
    this.status = BillUserStatus.initial,
    this.billUserList,
    this.detailBillUser,
    this.errorMessage,
  });

  BillUserState copyWith({
    BillUserStatus? status,
    List<BillUserModel>? billUserList,
    DetailBillUserModel? detailBillUser,
    String? errorMessage,
  }) {
    return BillUserState(
      status: status ?? this.status,
      billUserList: billUserList ?? this.billUserList,
      detailBillUser: detailBillUser ?? this.detailBillUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    billUserList,
    detailBillUser,
    errorMessage,
  ];
}
