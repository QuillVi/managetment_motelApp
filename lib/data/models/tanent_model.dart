class TenantModel {
  final int idNguoiThue;
  final String tenNguoiThue;
  final String? soDienThoai;
  final String? tenPhong;

  TenantModel({
    required this.idNguoiThue,
    required this.tenNguoiThue,
    this.soDienThoai,
    this.tenPhong,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      idNguoiThue: map['id_nguoidung'],
      tenNguoiThue: map['ten_nguoidung'],
      soDienThoai: map['sdt_nguoidung'],
      tenPhong: map['ten_phong'],
    );
  }
}
