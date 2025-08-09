class StatisticalModel {
  final int soToaNha;
  final int soPhong;
  final int tongSoNguoiThue;
  final int soPhongTrong;

  StatisticalModel({
    required this.soToaNha,
    required this.soPhong,
    required this.tongSoNguoiThue,
    required this.soPhongTrong,
  });

  factory StatisticalModel.fromMap(Map<String, dynamic> map) {
    return StatisticalModel(
      soToaNha: map['so_toa_nha'] ?? 0,
      soPhong: map['so_phong'] ?? 0,
      tongSoNguoiThue: map['tong_so_nguoi_thue'] ?? 0,
      soPhongTrong: map['so_phong_trong'] ?? 0,
    );
  }
}
