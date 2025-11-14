class ServiceModel {
  final int id_dichvu;
  final String ten_dichvu;
  final double phi_dichvu;
  final String? icon;

  ServiceModel({
    required this.id_dichvu,
    required this.ten_dichvu,
    required this.phi_dichvu,
    this.icon,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id_dichvu: map['id_dichvu'] ?? 0,
      ten_dichvu: map['ten_dichvu'] ?? '',
      phi_dichvu:
          map['phi_dichvu'] != null
              ? double.tryParse(map['phi_dichvu'].toString()) ?? 0.0
              : 0.0,
      icon: map['icon'],
    );
  }
}

class ServiceClosureModel {
  // --- Các trường đã cập nhật ---
  final int id_phong;
  final int id_toanha;
  final String? ten_phong;
  final String? ten_toanha;
  final String? dia_chi_toanha;
  final String? trang_thai_coc_phong;
  final String? trang_thai_chot_dich_vu;
  final String? trang_thai_phong;

  ServiceClosureModel({
    // Cập nhật constructor
    required this.id_phong,
    required this.id_toanha,
    this.ten_phong,
    this.ten_toanha,
    this.dia_chi_toanha,
    this.trang_thai_coc_phong,
    this.trang_thai_chot_dich_vu,
    this.trang_thai_phong,
  });

  // --- Cập nhật factory ---
  factory ServiceClosureModel.fromMap(Map<String, dynamic> map) {
    return ServiceClosureModel(
      // Các trường int (số nguyên), giả sử không bao giờ null từ API
      // Nếu có thể null, bạn nên dùng: map['id_phong'] ?? 0
      id_phong: map['id_phong'],
      id_toanha: map['id_toanha'],

      // Các trường String (chuỗi) khớp với key của JSON
      // Giữ logic '?? ""' (chuỗi rỗng) giống model gốc của bạn
      ten_phong: map['ten_phong'] ?? '',
      ten_toanha: map['ten_toanha'] ?? '',
      dia_chi_toanha: map['dia_chi_toanha'] ?? '',
      trang_thai_coc_phong: map['trang_thai_coc_phong'] ?? '',
      trang_thai_chot_dich_vu: map['trang_thai_chot_dich_vu'] ?? '',
      trang_thai_phong: map['trang_thai_phong'] ?? '',
    );
  }
}
