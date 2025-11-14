// File: owe_state.dart (Cần thêm/sửa đổi)

import 'package:motelapp/data/models/owe_model.dart';

enum OweStatus { initial, loading, loaded, error }

class OweState {
  // Thay thế status chung bằng hai trạng thái độc lập
  final OweStatus collectStatus;
  final OweStatus doneStatus;
  final List<OweModel> collectDebts;
  final List<OweModel> doneDebts;
  final String? error;

  const OweState({
    this.collectStatus = OweStatus.initial, // Sử dụng trạng thái độc lập
    this.doneStatus = OweStatus.initial, // Sử dụng trạng thái độc lập
    this.collectDebts = const [],
    this.doneDebts = const [],
    this.error,
  });

  OweState copyWith({
    OweStatus? collectStatus, // Cập nhật trường copyWith
    OweStatus? doneStatus, // Cập nhật trường copyWith
    List<OweModel>? collectDebts,
    List<OweModel>? doneDebts,
    String? error,
  }) {
    return OweState(
      collectStatus: collectStatus ?? this.collectStatus,
      doneStatus: doneStatus ?? this.doneStatus,
      collectDebts: collectDebts ?? this.collectDebts,
      doneDebts: doneDebts ?? this.doneDebts,
      error: error,
    );
  }
}
