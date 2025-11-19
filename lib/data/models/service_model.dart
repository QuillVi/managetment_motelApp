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

class BuildingInfoModel {
  final int id_toanha;
  final String ten_toanha;

  BuildingInfoModel({required this.id_toanha, required this.ten_toanha});

  factory BuildingInfoModel.fromMap(Map<String, dynamic> map) {
    return BuildingInfoModel(
      id_toanha: map['id_toanha'] ?? 0,
      ten_toanha: map['ten_toanha'] ?? '',
    );
  }
}

class DetailServiceModel {
  final int id_dichvu;
  final String ten_dichvu;
  final String cach_tinh_phi;
  final double phi_dichvu;
  final String don_vi_do;
  final String? icon;
  final String ghi_chu;
  // THAY ĐỔI: Từ String -> List<BuildingInfoModel>
  final List<BuildingInfoModel> danh_sach_toa_nha;

  DetailServiceModel({
    required this.id_dichvu,
    required this.ten_dichvu,
    required this.cach_tinh_phi,
    required this.phi_dichvu,
    required this.don_vi_do,
    this.icon,
    required this.ghi_chu,
    required this.danh_sach_toa_nha, // <-- Đã cập nhật
  });

  factory DetailServiceModel.fromMap(Map<String, dynamic> map) {
    // Logic xử lý danh sách toà nhà
    List<BuildingInfoModel> toaNhaList = [];
    if (map['danh_sach_toa_nha'] != null && map['danh_sach_toa_nha'] is List) {
      // Lặp qua danh sách thô từ API
      for (var item in (map['danh_sach_toa_nha'] as List)) {
        // Kiểm tra item không phải null và là một Map (giống JSON)
        if (item != null && item is Map<String, dynamic>) {
          toaNhaList.add(BuildingInfoModel.fromMap(item));
        }
      }
    }

    return DetailServiceModel(
      // int, xử lý null
      id_dichvu: map['id_dichvu'] ?? 0,

      // String, xử lý null (mặc định là chuỗi rỗng)
      ten_dichvu: map['ten_dichvu'] ?? '',
      cach_tinh_phi: map['cach_tinh_phi'] ?? '',
      don_vi_do: map['don_vi_do'] ?? '',
      ghi_chu: map['ghi_chu'] ?? '',

      // THAY ĐỔI: Gán danh sách đã được parse
      danh_sach_toa_nha: toaNhaList,

      // double, xử lý parse từ String
      phi_dichvu:
          map['phi_dichvu'] != null
              ? double.tryParse(map['phi_dichvu'].toString()) ?? 0.0
              : 0.0,

      // String? (nullable)
      icon: map['icon'],
    );
  }
}
