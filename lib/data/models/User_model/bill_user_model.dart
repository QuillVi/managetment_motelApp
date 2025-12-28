class BillUserModel {
  final int? idNguoithue;
  final String? tenNguoithue;
  final String? tenPhong;
  final String? tenToanha;
  final String? trangThaiPhong;
  final int? idHoadon;
  final String? tenHoadon;
  final DateTime? ngayThang;
  final String? trangThaiHoaDon;
  final DateTime? hanThanhToan;
  final double? tongTienDichVu;
  final double? tongHopTien;
  final String? ghiChuHoaDon;

  BillUserModel({
    this.idNguoithue,
    this.tenNguoithue,
    this.tenPhong,
    this.tenToanha,
    this.trangThaiPhong,
    this.idHoadon,
    this.tenHoadon,
    this.ngayThang,
    this.trangThaiHoaDon,
    this.hanThanhToan,
    this.tongTienDichVu,
    this.tongHopTien,
    this.ghiChuHoaDon,
  });

  // Đổi fromJson -> fromMap
  factory BillUserModel.fromMap(Map<String, dynamic> map) {
    return BillUserModel(
      idNguoithue: map['id_nguoithue'] as int?,
      tenNguoithue: map['ten_nguoithue'] as String?,
      tenPhong: map['ten_phong'] as String?,
      tenToanha: map['ten_toanha'] as String?,
      trangThaiPhong: map['trang_thai_phong'] as String?,
      idHoadon: map['id_hoadon'] as int?,
      tenHoadon: map['ten_hoadon'] as String?,
      // Parse chuỗi ngày tháng sang DateTime
      ngayThang:
          map['ngay_thang'] != null
              ? DateTime.tryParse(map['ngay_thang'])
              : null,
      trangThaiHoaDon: map['trang_thai_hoa_don'] as String?,
      hanThanhToan:
          map['han_thanh_toan'] != null
              ? DateTime.tryParse(map['han_thanh_toan'])
              : null,
      // Parse chuỗi số tiền ("350000.00") sang double an toàn
      tongTienDichVu:
          map['tong_tien_dich_vu'] != null
              ? double.tryParse(map['tong_tien_dich_vu'].toString())
              : 0.0,
      tongHopTien:
          map['tong_hop_tien'] != null
              ? double.tryParse(map['tong_hop_tien'].toString())
              : 0.0,
      ghiChuHoaDon: map['ghi_chu_hoa_don'] as String?,
    );
  }
}

double _parseDouble(dynamic value) {
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  } else if (value is num) {
    return value.toDouble();
  }
  return 0.0;
}

DateTime? _parseDateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

class DetailBillUserModel {
  final int idHoadon;
  final int idHopdong;
  final int idNguoidung;
  final String tenPhong;
  final double giaPhong;
  final double tienDatCoc;
  final String tenToanha;
  final String ten;
  final String trangThai;
  final DateTime? ngayThang;
  final DateTime? ngayThanhToan;
  final DateTime? hanThanhToan;
  final String trangThaiHoaDon;
  final double tongTienDichVu;
  final double tongHopTien;
  final int thoiHan;
  final String? ghiChuHoaDon;

  DetailBillUserModel({
    required this.idHoadon,
    required this.idHopdong,
    required this.idNguoidung,
    required this.tenPhong,
    required this.giaPhong,
    required this.tienDatCoc,
    required this.tenToanha,
    required this.ten,
    required this.trangThai,
    this.ngayThang,
    this.ngayThanhToan,
    required this.hanThanhToan,
    required this.trangThaiHoaDon,
    required this.tongTienDichVu,
    required this.tongHopTien,
    required this.thoiHan,
    this.ghiChuHoaDon,
  });

  factory DetailBillUserModel.fromMap(Map<String, dynamic> json) {
    return DetailBillUserModel(
      idHoadon: json['id_hoadon'] ?? 0,
      idHopdong: json['id_hopdong'] ?? 0,
      idNguoidung: json['id_nguoidung'] ?? 0,
      tenPhong: json['ten_phong'] ?? '',
      giaPhong: _parseDouble(json['gia_phong']),
      tienDatCoc: _parseDouble(json['tien_dat_coc']),
      tenToanha: json['ten_toanha'] ?? '',
      ten: json['ten'] ?? '',
      trangThai: json['trang_thai'] ?? '',
      ngayThang: _parseDateTime(json['ngay_thang']),
      ngayThanhToan: _parseDateTime(json['ngay_thanh_toan']),
      hanThanhToan: _parseDateTime(json['han_thanh_toan']),
      trangThaiHoaDon: json['trang_thai_hoa_don'] ?? '',
      tongTienDichVu: _parseDouble(json['tong_tien_dich_vu']),
      tongHopTien: _parseDouble(json['tong_hop_tien']),
      thoiHan: json['thoi_han'] ?? 0,
      ghiChuHoaDon: json['ghi_chu_hoa_don'],
    );
  }
}
