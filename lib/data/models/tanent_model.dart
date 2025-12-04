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

class TenantDetailContractModel {
  final int idNguoiThue;
  final String tenNguoiThue;
  final String? soDienThoai;
  // Các trường mới bổ sung
  final String? ngaySinh;
  final String? hkThuongTru;
  final String? cccd;
  final String? ngayCap;
  final String? noiCap;

  TenantDetailContractModel({
    required this.idNguoiThue,
    required this.tenNguoiThue,
    this.soDienThoai,
    this.ngaySinh,
    this.hkThuongTru,
    this.cccd,
    this.ngayCap,
    this.noiCap,
  });

  factory TenantDetailContractModel.fromMap(Map<String, dynamic> map) {
    return TenantDetailContractModel(
      // Mapping linh hoạt: ưu tiên key mới, nếu không có thì tìm key cũ
      idNguoiThue: map['id_nguoi_thue'] ?? map['id_nguoidung'] ?? 0,
      tenNguoiThue: map['ten_nguoi_thue'] ?? map['ten_nguoidung'] ?? '',
      soDienThoai: map['sdt_nguoi_thue'] ?? map['sdt_nguoidung'],

      // Map các trường mới từ JSON
      ngaySinh: map['ngay_sinh_nguoi_thue'],
      hkThuongTru: map['hk_thuong_tru_nguoi_thue'],
      cccd: map['cmnd_cccd_nguoi_thue'],
      ngayCap: map['ngay_cap_cmnd_nguoi_thue'],
      noiCap: map['noi_cap_cmnd_nguoi_thue'],
    );
  }
}
