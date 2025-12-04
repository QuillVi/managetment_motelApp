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
  //Bỏ dấu '?' vì ta sẽ xử lý null ngay trong factory
  final int idPhong;
  final int idToanha;
  final String tenPhong;
  final String tenToanha;
  final String diaChiToanha;
  final String trangThaiCocPhong;
  final String? trangThaiChotDichVu;
  final String trangThaiPhong;

  ServiceClosureModel({
    required this.idPhong,
    required this.idToanha,
    required this.tenPhong,
    required this.tenToanha,
    required this.diaChiToanha,
    required this.trangThaiCocPhong,
    this.trangThaiChotDichVu,
    required this.trangThaiPhong,
  });

  factory ServiceClosureModel.fromMap(Map<String, dynamic> map) {
    return ServiceClosureModel(
      // Mapping từ key JSON (snake_case) sang biến Dart (camelCase)

      // Thêm ?? 0 để tránh crash nếu API trả null hoặc thiếu key
      idPhong: map['id_phong'] ?? 0,
      idToanha: map['id_toanha'] ?? 0,

      // Luôn trả về chuỗi rỗng nếu null, giúp UI không bị lỗi hiển thị
      tenPhong: map['ten_phong'] ?? '',
      tenToanha: map['ten_toanha'] ?? '',
      diaChiToanha: map['dia_chi_toanha'] ?? '',
      trangThaiCocPhong: map['trang_thai_coc_phong'] ?? '',
      trangThaiChotDichVu: map['trang_thai_chot_dich_vu'] ?? '',
      trangThaiPhong: map['trang_thai_phong'] ?? '',
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
