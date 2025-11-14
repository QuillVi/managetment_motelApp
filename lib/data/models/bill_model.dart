class BillModel {
  final int id_hoadon;
  final int id_hopdong;
  final int id_nguoithue; // API trả về 'id_nguoidung'
  final String ten_phong;
  final String ten_toanha;
  final String ten_nguoithue; // API trả về 'ten'
  final String trang_thai_thue_phong; // API trả về 'trang_thai'
  final String ngay_thanh_toan; // API trả về 'ngay_thang'
  final String trang_thai_hoa_don;

  // ⭐️ BỔ SUNG: Các trường còn thiếu từ API
  final double gia_phong;
  final double tong_tien_dich_vu;
  final double tong_hop_tien;

  BillModel({
    required this.id_hoadon,
    required this.id_hopdong,
    required this.id_nguoithue,
    required this.ten_phong,
    required this.ten_toanha,
    required this.ten_nguoithue,
    required this.trang_thai_thue_phong,
    required this.ngay_thanh_toan,
    required this.trang_thai_hoa_don,

    // ⭐️ BỔ SUNG: Thêm vào constructor
    required this.gia_phong,
    required this.tong_tien_dich_vu,
    required this.tong_hop_tien,
  });

  /// Hàm hỗ trợ chuyển đổi String sang double an toàn
  static double _safeParseDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '0.0') ?? 0.0;
  }

  factory BillModel.fromMap(Map<String, dynamic> json) {
    return BillModel(
      // Các trường cũ đã đúng
      id_hoadon: json['id_hoadon'],
      id_hopdong: json['id_hopdong'],
      id_nguoithue:
          json['id_nguoidung'], // Sửa 'id_nguoithue' -> 'id_nguoidung'
      ten_phong: json['ten_phong'],
      ten_toanha: json['ten_toanha'],
      ten_nguoithue: json['ten'],
      trang_thai_thue_phong: json['trang_thai'],
      ngay_thanh_toan: json['ngay_thang'],
      trang_thai_hoa_don: json['trang_thai_hoa_don'],

      // ⭐️ BỔ SUNG: Parse các trường số liệu
      // Dùng _safeParseDouble để tránh lỗi nếu API trả về null
      gia_phong: _safeParseDouble(json['gia_phong']),
      tong_tien_dich_vu: _safeParseDouble(json['tong_tien_dich_vu']),
      tong_hop_tien: _safeParseDouble(json['tong_hop_tien']),
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

class DetailBillModel {
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

  DetailBillModel({
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

  factory DetailBillModel.fromMap(Map<String, dynamic> json) {
    return DetailBillModel(
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
