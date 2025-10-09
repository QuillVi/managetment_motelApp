class ContractModel {
  final int idHopDong;
  final String ngayBatDau;
  final int thoiHan;

  ContractModel({
    required this.idHopDong,
    required this.ngayBatDau,
    required this.thoiHan,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      idHopDong: map['id_hopdong'] ?? 0,
      ngayBatDau: map['ngay_batdau'] ?? '',
      thoiHan: map['thoi_han'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_hopdong': idHopDong,
      'ngay_batdau': ngayBatDau,
      'thoi_han': thoiHan,
    };
  }
}
