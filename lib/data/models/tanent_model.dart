class TenantModel {
  final int idNguoiDung;
  final String tenNguoiDung;
  final String? soDienThoai;
  final String? tenPhong;

  TenantModel({
    required this.idNguoiDung,
    required this.tenNguoiDung,
    this.soDienThoai,
    this.tenPhong,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      idNguoiDung: map['id_nguoidung'],
      tenNguoiDung: map['ten_nguoidung'],
      soDienThoai: map['sdt'],
      tenPhong: map['ten_phong'],
    );
  }
}
