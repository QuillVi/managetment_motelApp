class CostModel {
  final int idHoaDon;
  final String tongThu;
  final String khoangThu;
  final String ngayThanhToan;
  final String tenPhong;
  final String tenToaNha;
  final String? trangThaiHoaDon;

  CostModel({
    required this.idHoaDon,
    required this.tongThu,
    required this.khoangThu,
    required this.ngayThanhToan,
    required this.tenPhong,
    required this.tenToaNha,
    this.trangThaiHoaDon,
  });

  factory CostModel.fromMap(Map<String, dynamic> map) {
    return CostModel(
      idHoaDon: map['id_hoadon'] ?? 0,
      tongThu: map['tong_hop_tien'] ?? '',
      khoangThu: map['tong_tien_chua_thanh_toan'] ?? '',
      ngayThanhToan: map['ngay_thanh_toan'] ?? '',
      tenPhong: map['ten_phong'] ?? '',
      tenToaNha: map['ten_toanha'] ?? '',
      trangThaiHoaDon: map['trang_thai_hoadon'] ?? '',
    );
  }
}

class CostDetailModel {
  final int idHoaDon;
  final String tongHopTien;
  final String ngayThanhToan;
  final String? phuongThucThanhToan;
  final String? ghiChuHoaDon;
  final String trangThaiHoaDon;
  final String tenPhong;
  final String tenToaNha;
  final String tenNguoiThanhToan;

  CostDetailModel({
    required this.idHoaDon,
    required this.tongHopTien,
    required this.ngayThanhToan,
    this.phuongThucThanhToan,
    this.ghiChuHoaDon,
    required this.trangThaiHoaDon,
    required this.tenPhong,
    required this.tenToaNha,
    required this.tenNguoiThanhToan,
  });

  factory CostDetailModel.fromMap(Map<String, dynamic> map) {
    return CostDetailModel(
      idHoaDon: map['id_hoadon'] ?? 0,
      tongHopTien: map['tong_hop_tien'] ?? '',
      ngayThanhToan: map['ngay_thanh_toan'] ?? '',
      phuongThucThanhToan: map['phuong_thuc_thanh_toan'],
      ghiChuHoaDon: map['ghi_chu_hoa_don'],
      trangThaiHoaDon: map['trang_thai_hoa_don'] ?? '',
      tenPhong: map['ten_phong'] ?? '',
      tenToaNha: map['ten_toanha'] ?? '',
      tenNguoiThanhToan: map['ten_nguoi_thue'] ?? '',
    );
  }
}
