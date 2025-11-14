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

class ListContractModel {
  final int id_hopdong;
  final String ten_phong;
  final String ten_toanha;
  final String ngay_batdau;
  final int thoi_han;
  final String trang_thai;
  final String ten_quanly;

  ListContractModel({
    required this.id_hopdong,
    required this.ten_phong,
    required this.ten_toanha,
    required this.ngay_batdau,
    required this.thoi_han,
    required this.trang_thai,
    required this.ten_quanly,
  });

  factory ListContractModel.fromMap(Map<String, dynamic> map) {
    return ListContractModel(
      id_hopdong: map['id_hopdong'] ?? 0,
      ten_phong: map['ten_phong'] ?? '',
      ten_toanha: map['ten_toanha'] ?? '',
      ngay_batdau: map['ngay_batdau'] ?? '',
      thoi_han: map['thoi_han'] ?? 0,
      trang_thai: map['trang_thai'] ?? '',
      ten_quanly: map['ten_nguoi_quan_ly'] ?? '',
    );
  }
}
