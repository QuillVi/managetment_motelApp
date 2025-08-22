class RoomModel {
  final int idPhong;
  final String tenPhong;
  final int soTang;
  final int phongNgu;
  final int phongKhach;
  final double dienTich;
  final double giaPhong;
  final double tienDatCoc;
  final int soNguoiThue;
  final String? anhPhong;
  final int idToaNha;

  RoomModel({
    required this.idPhong,
    required this.tenPhong,
    required this.soTang,
    required this.phongNgu,
    required this.phongKhach,
    required this.dienTich,
    required this.giaPhong,
    required this.tienDatCoc,
    required this.soNguoiThue,
    this.anhPhong,
    required this.idToaNha,
  });

  /// Tạo object từ Map (API trả về)
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      idPhong: map['id_phong'] ?? 0,
      tenPhong: map['ten_phong'] ?? '',
      soTang: map['so_tang'] ?? 0,
      phongNgu: map['phong_ngu'] ?? 0,
      phongKhach: map['phong_khach'] ?? 0,
      // API trả về "dientich" (không có "_")
      dienTich: double.tryParse(map['dientich'].toString()) ?? 0,
      giaPhong: double.tryParse(map['gia_phong'].toString()) ?? 0,
      tienDatCoc: double.tryParse(map['tien_dat_coc'].toString()) ?? 0,
      soNguoiThue: map['so_nguoi_thue'] ?? 0,
      anhPhong: map['anh_phong'],
      idToaNha: map['id_toanha'] ?? 0,
    );
  }

  /// Tạo object từ JSON string
  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      RoomModel.fromMap(json);

  /// Convert object -> Map
  Map<String, dynamic> toMap() {
    return {
      'id_phong': idPhong,
      'ten_phong': tenPhong,
      'so_tang': soTang,
      'phong_ngu': phongNgu,
      'phong_khach': phongKhach,
      'dientich': dienTich,
      'gia_phong': giaPhong,
      'tien_dat_coc': tienDatCoc,
      'so_nguoi_thue': soNguoiThue,
      'anh_phong': anhPhong,
      'id_toanha': idToaNha,
    };
  }

  /// Convert object -> JSON string
  Map<String, dynamic> toJson() => toMap();
}
