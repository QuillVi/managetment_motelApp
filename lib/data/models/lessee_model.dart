class LesseeModel {
  final int idNguoiDung;
  final String tenNguoiDung;
  final String? soDienThoai;
  final String? tenPhong;
  final String? tenToaNha;

  LesseeModel({
    required this.idNguoiDung,
    required this.tenNguoiDung,
    this.soDienThoai,
    this.tenPhong,
    this.tenToaNha,
  });

  factory LesseeModel.fromMap(Map<String, dynamic> map) {
    return LesseeModel(
      idNguoiDung: map['id_nguoidung'],
      tenNguoiDung: map['ten'],
      soDienThoai: map['sdt'],
      tenPhong: map['ten_phong'],
      tenToaNha: map['ten_toanha'],
    );
  }
}
