import 'package:equatable/equatable.dart';
import 'package:motelapp/data/models/bill_model.dart';

enum BillStatus { initial, loading, loaded, error }

class BillState extends Equatable {
  final BillStatus status;
  final List<BillModel>? billModel;
  final DetailBillModel? detailBillModel;
  final String? errorMessage;

  const BillState({
    this.status = BillStatus.initial,
    this.billModel,
    this.detailBillModel,
    this.errorMessage,
  });

  BillState copyWith({
    BillStatus? status,
    List<BillModel>? billModel,
    DetailBillModel? detailBillModel,
    String? errorMessage,
  }) {
    return BillState(
      status: status ?? this.status,
      billModel: billModel ?? this.billModel,
      detailBillModel: detailBillModel ?? this.detailBillModel,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, billModel, detailBillModel];
}
