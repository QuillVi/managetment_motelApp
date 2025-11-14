class StakeModel {
  // 1. Đổi tên biến cho đúng chuẩn Dart (camelCase) và đúng với JSON
  final String trangThaiCoc;
  final int soLuongCoc;
  final String tongTienCoc; // <-- Sửa từ 'tienCoc'

  StakeModel({
    required this.trangThaiCoc,
    required this.soLuongCoc,
    required this.tongTienCoc, // <-- Sửa ở constructor
  });

  // 2. Sửa lại factory 'fromMap'
  factory StakeModel.fromMap(Map<String, dynamic> map) {
    return StakeModel(
      // Key 'trang_thai_coc' đã đúng
      trangThaiCoc: map['trang_thai_coc'] ?? '',

      // Key 'so_luong_coc' đã đúng
      soLuongCoc: map['so_luong_coc'] ?? 0,

      // 3. Sửa key từ 'tien_coc' -> 'tong_tien_coc'
      tongTienCoc: map['tong_tien_coc'] ?? '0',
    );
  }
}

class ContentStakeModel {
  // 1. Đổi tên biến cho đúng chuẩn Dart (lowerCamelCase)
  final int idNguoiDung;
  final String? ten;
  final String? tenPhong;
  final String? tenToanha;
  final String? tienCoc;
  final String? ngayBatdau;
  final String? trangThaiCoc;

  ContentStakeModel({
    required this.idNguoiDung,
    this.ten,
    this.tenPhong,
    this.tenToanha,
    this.tienCoc,
    this.ngayBatdau,
    this.trangThaiCoc,
  });

  // 2. Sửa lại factory 'fromMap' để đọc đúng key
  factory ContentStakeModel.fromMap(Map<String, dynamic> map) {
    return ContentStakeModel(
      // Sửa ở đây
      idNguoiDung: map['id_nguoidung'], // <-- Lỗi 1: Đọc 'id_nguoidung'
      ten: map['ten'] ?? '', // <-- Lỗi 2: Đọc 'ten'
      // Các key này đã đúng
      tenPhong: map['ten_phong'] ?? '',
      tenToanha: map['ten_toanha'] ?? '',
      tienCoc: map['tien_coc'] ?? '',
      ngayBatdau: map['ngay_batdau'] ?? '',
      trangThaiCoc: map['trang_thai_coc'] ?? '',
    );
  }
}
