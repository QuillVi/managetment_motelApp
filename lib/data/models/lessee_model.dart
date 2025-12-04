class LesseeModel {
  final int idNguoiThue;
  final String tenNguoiThue;
  final String? soDienThoai;
  final String? tenPhong;
  final String? tenToaNha;
  final String? trangThaiHopDong;

  LesseeModel({
    required this.idNguoiThue,
    required this.tenNguoiThue,
    this.soDienThoai,
    this.tenPhong,
    this.tenToaNha,
    this.trangThaiHopDong,
  });

  factory LesseeModel.fromMap(Map<String, dynamic> map) {
    return LesseeModel(
      idNguoiThue: map['id_nguoidung'] ?? 0,
      tenNguoiThue: map['ten_nguoi_thue'] ?? 'Chưa cập nhật',
      soDienThoai: map['sdt_nguoi_thue'],
      tenPhong: map['ten_phong'],
      tenToaNha: map['ten_toanha'],
      trangThaiHopDong: map['trang_thai_hop_dong'],
    );
  }
}
