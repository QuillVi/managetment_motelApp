class OweModel {
  final int idHoaDon;
  final int idNguoiDung; // Đã sửa (từ idNguoiThue)
  final String tenNguoiThue;
  final String tenPhong;
  final String tenToaNha;
  final String trangThaiHoaDon; // Đã sửa (từ trangThaiHopDong)
  final String trangThaiHopDong; // Trường mới
  final String? soTienNo;

  OweModel({
    required this.idHoaDon,
    required this.idNguoiDung,
    required this.tenNguoiThue,
    required this.tenPhong,
    required this.tenToaNha,
    required this.trangThaiHoaDon,
    required this.trangThaiHopDong, // Trường mới
    this.soTienNo,
  });

  factory OweModel.fromMap(Map<String, dynamic> json) {
    return OweModel(
      // Sửa tên biến `idHopDong` -> `idHoaDon`, key 'id_hoadon' đã đúng
      idHoaDon: json['id_hoadon'],

      // Sửa key 'id_nguoithue' -> 'id_nguoidung'
      // Sửa tên biến `idNguoiThue` -> `idNguoiDung`
      idNguoiDung: json['id_nguoidung'],

      tenNguoiThue: json['ten_nguoi_thue'],
      tenPhong: json['ten_phong'],
      tenToaNha: json['ten_toanha'],

      // Sửa tên biến `trangThaiHopDong` -> `trangThaiHoaDon`
      // Key 'trang_thai_hoadon' đã đúng
      trangThaiHoaDon: json['trang_thai_hoadon'],

      // Thêm trường mới để lấy 'trang_thai_hopdong' từ JSON
      trangThaiHopDong: json['trang_thai_hopdong'],

      soTienNo: json['so_tien_no'],
    );
  }
}
