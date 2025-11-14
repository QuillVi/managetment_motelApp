class LesseeModel {
  final int idNguoiThue;
  final String tenNguoiThue;
  final String? soDienThoai;
  final String? tenPhong;
  final String? tenToaNha;

  LesseeModel({
    required this.idNguoiThue,
    required this.tenNguoiThue,
    this.soDienThoai,
    this.tenPhong,
    this.tenToaNha,
  });

  factory LesseeModel.fromMap(Map<String, dynamic> map) {
    return LesseeModel(
      idNguoiThue: map['id_nguoithue'],
      tenNguoiThue: map['ten_nguoithue'],
      soDienThoai: map['sdt_nguoithue'],
      tenPhong: map['ten_phong'],
      tenToaNha: map['ten_toanha'],
    );
  }
}
